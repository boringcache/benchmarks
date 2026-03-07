#!/usr/bin/env bash
# -----------------------------------------------------------------------
# proxy-diagnostics-to-summary.sh
#
# Parses a BoringCache proxy log and optional request-metrics JSONL file,
# then writes structured diagnostics to $GITHUB_STEP_SUMMARY so they are
# visible via the GitHub API (no artifact download needed).
#
# Usage:
#   proxy-diagnostics-to-summary.sh \
#     --proxy-log <path>            (required) \
#     --metrics-jsonl <path>        (optional) \
#     --phase <seed|warm1|warm2|stale> (required) \
#     --benchmark-id <id>           (required)
# -----------------------------------------------------------------------
set -euo pipefail

proxy_log=""
metrics_jsonl=""
phase=""
benchmark_id=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --proxy-log)      proxy_log="$2";      shift 2 ;;
    --metrics-jsonl)  metrics_jsonl="$2";   shift 2 ;;
    --phase)          phase="$2";           shift 2 ;;
    --benchmark-id)   benchmark_id="$2";   shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$proxy_log" || -z "$phase" || -z "$benchmark_id" ]]; then
  echo "Missing required arguments (--proxy-log, --phase, --benchmark-id)" >&2
  exit 1
fi

summary_file="${GITHUB_STEP_SUMMARY:-/dev/stdout}"

{
  echo "## Proxy Diagnostics: ${benchmark_id} / ${phase}"
  echo ""

  # ---- 1. Preload / prefetch status from proxy log ----
  if [[ -f "$proxy_log" ]]; then
    echo "### Index Preload"
    echo '```'
    grep -E 'KV index preload' "$proxy_log" 2>/dev/null || echo "(no KV index preload lines found)"
    echo '```'
    echo ""

    echo "### Blob Prefetch"
    echo '```'
    grep -E 'blob preload|prefetch|PREFETCH' "$proxy_log" 2>/dev/null || echo "(no blob prefetch lines found)"
    echo '```'
    echo ""

    # Extract key numbers if available
    preload_entries=$(grep -oP 'KV index preloaded:\s*\K[0-9]+' "$proxy_log" 2>/dev/null | tail -n1 || true)
    prefetch_downloaded=$(grep -oP 'downloaded=\K[0-9]+' "$proxy_log" 2>/dev/null | tail -n1 || true)
    prefetch_skipped=$(grep -oP 'skipped=\K[0-9]+' "$proxy_log" 2>/dev/null | tail -n1 || true)
    prefetch_failed=$(grep -oP 'failed=\K[0-9]+' "$proxy_log" 2>/dev/null | tail -n1 || true)
    prefetch_bytes=$(grep -oP 'total_bytes=\K[0-9]+' "$proxy_log" 2>/dev/null | tail -n1 || true)
    prefetch_elapsed=$(grep -oP 'elapsed=\K[0-9.]+s' "$proxy_log" 2>/dev/null | tail -n1 || true)

    echo "### Prefetch Summary"
    echo ""
    echo "| Metric | Value |"
    echo "|---|---|"
    echo "| Index entries preloaded | ${preload_entries:-n/a} |"
    echo "| Blobs downloaded (prefetch) | ${prefetch_downloaded:-n/a} |"
    echo "| Blobs skipped (prefetch) | ${prefetch_skipped:-n/a} |"
    echo "| Blobs failed (prefetch) | ${prefetch_failed:-n/a} |"
    if [[ -n "$prefetch_bytes" ]]; then
      prefetch_mib=$(awk -v b="$prefetch_bytes" 'BEGIN { printf "%.2f", b / 1048576 }')
      echo "| Prefetch total bytes | ${prefetch_bytes} (${prefetch_mib} MiB) |"
    else
      echo "| Prefetch total bytes | n/a |"
    fi
    echo "| Prefetch elapsed | ${prefetch_elapsed:-n/a} |"
    echo ""

    # ---- 2. Errors and warnings ----
    error_count=$(grep -ciE 'error|Error|ERROR' "$proxy_log" 2>/dev/null || echo "0")
    echo "### Errors"
    echo ""
    echo "Total error-like lines: ${error_count}"
    echo ""
    if [[ "$error_count" -gt 0 ]]; then
      echo '<details><summary>Error lines (up to 50)</summary>'
      echo ""
      echo '```'
      grep -iE 'error|Error|ERROR' "$proxy_log" 2>/dev/null | head -n 50 || true
      echo '```'
      echo '</details>'
      echo ""
    fi

    # ---- 3. HEARTBEAT lines (show proxy activity / throughput) ----
    heartbeat_count=$(grep -c 'HEARTBEAT' "$proxy_log" 2>/dev/null || echo "0")
    if [[ "$heartbeat_count" -gt 0 ]]; then
      echo "### Heartbeats (${heartbeat_count} total)"
      echo ""
      echo '<details><summary>First and last 5 heartbeats</summary>'
      echo ""
      echo '```'
      grep 'HEARTBEAT' "$proxy_log" 2>/dev/null | head -n 5 || true
      echo "..."
      grep 'HEARTBEAT' "$proxy_log" 2>/dev/null | tail -n 5 || true
      echo '```'
      echo '</details>'
      echo ""
    fi
  else
    echo "> Proxy log not found at \`${proxy_log}\`"
    echo ""
  fi

  # ---- 4. Request metrics from JSONL ----
  if [[ -n "$metrics_jsonl" && -f "$metrics_jsonl" ]]; then
    total_records=$(wc -l < "$metrics_jsonl" 2>/dev/null || echo "0")
    echo "### Request Metrics (${total_records} records)"
    echo ""

    if [[ "$total_records" -gt 0 ]] && command -v jq &>/dev/null; then
      # Count by operation
      echo "#### Operations breakdown"
      echo '```'
      jq -r '.operation // "unknown"' "$metrics_jsonl" 2>/dev/null | sort | uniq -c | sort -rn || true
      echo '```'
      echo ""

      # Failures
      failure_count=$(jq -r 'select(.error != null or ((.status // 0) >= 500)) | .operation' "$metrics_jsonl" 2>/dev/null | wc -l || echo "0")
      echo "Failures (error or 5xx): ${failure_count}"
      echo ""

      # P95 latencies by operation
      echo "#### Latency percentiles (ms)"
      echo ""
      echo "| Operation | Count | P50 | P95 | P99 | Max |"
      echo "|---|---|---|---|---|---|"

      for op in cache_blobs_check cache_blobs_download_urls cache_flush_upload cache_finalize_publish blob_prefetch_cycle; do
        durations=$(jq -r "select(.operation == \"${op}\") | .duration_ms // empty" "$metrics_jsonl" 2>/dev/null | sort -n)
        count=$(echo "$durations" | grep -c . 2>/dev/null || echo "0")
        if [[ "$count" -gt 0 ]]; then
          p50_idx=$(( (count * 50 + 99) / 100 ))
          p95_idx=$(( (count * 95 + 99) / 100 ))
          p99_idx=$(( (count * 99 + 99) / 100 ))
          p50=$(echo "$durations" | sed -n "${p50_idx}p")
          p95=$(echo "$durations" | sed -n "${p95_idx}p")
          p99=$(echo "$durations" | sed -n "${p99_idx}p")
          max_val=$(echo "$durations" | tail -n1)
          echo "| ${op} | ${count} | ${p50} | ${p95} | ${p99} | ${max_val} |"
        fi
      done
      echo ""

      # Retry events
      retry_count=$(jq -r 'select((.retry_count // 0) > 0) | .operation' "$metrics_jsonl" 2>/dev/null | wc -l || echo "0")
      echo "Retry events: ${retry_count}"
      echo ""

      # Cache ops summary (hits/misses)
      cache_ops_count=$(jq -r 'select(.operation == "cache_ops_record") | .details // empty' "$metrics_jsonl" 2>/dev/null | wc -l || echo "0")
      if [[ "$cache_ops_count" -gt 0 ]]; then
        echo "#### Cache operations (${cache_ops_count} records)"
        echo '```'
        jq -r 'select(.operation == "cache_ops_record") | .details // empty' "$metrics_jsonl" 2>/dev/null \
          | grep -oP 'result=\K\w+' | sort | uniq -c | sort -rn || true
        echo '```'
        echo ""
      fi
    else
      echo "(jq not available or no records — raw tail below)"
      echo '```'
      tail -n 20 "$metrics_jsonl" 2>/dev/null || true
      echo '```'
      echo ""
    fi
  elif [[ -n "$metrics_jsonl" ]]; then
    echo "> Metrics JSONL not found at \`${metrics_jsonl}\`"
    echo ""
  fi

  # ---- 5. Full proxy log tail (collapsible) ----
  if [[ -f "$proxy_log" ]]; then
    echo '<details><summary>Full proxy log (last 500 lines)</summary>'
    echo ""
    echo '```'
    tail -n 500 "$proxy_log" 2>/dev/null || true
    echo '```'
    echo '</details>'
  fi

} >> "$summary_file"

# ---- 6. Write key metrics to GITHUB_OUTPUT (for step/job outputs) ----
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    echo "diag_phase=${phase}"
    echo "diag_index_entries=${preload_entries:-0}"
    echo "diag_prefetch_downloaded=${prefetch_downloaded:-0}"
    echo "diag_prefetch_skipped=${prefetch_skipped:-0}"
    echo "diag_prefetch_failed=${prefetch_failed:-0}"
    echo "diag_prefetch_bytes=${prefetch_bytes:-0}"
    echo "diag_prefetch_elapsed=${prefetch_elapsed:-unknown}"
    echo "diag_error_count=${error_count:-0}"

    # Request metrics if available
    if [[ -n "$metrics_jsonl" && -f "$metrics_jsonl" ]] && command -v jq &>/dev/null; then
      total_records=$(wc -l < "$metrics_jsonl" 2>/dev/null || echo "0")
      failure_count=$(jq -r 'select(.error != null or ((.status // 0) >= 500)) | .operation' "$metrics_jsonl" 2>/dev/null | wc -l || echo "0")
      retry_count=$(jq -r 'select((.retry_count // 0) > 0) | .operation' "$metrics_jsonl" 2>/dev/null | wc -l || echo "0")

      # P95 for key operations
      for op in cache_blobs_check cache_blobs_download_urls; do
        durations=$(jq -r "select(.operation == \"${op}\") | .duration_ms // empty" "$metrics_jsonl" 2>/dev/null | sort -n)
        count=$(echo "$durations" | grep -c . 2>/dev/null || echo "0")
        if [[ "$count" -gt 0 ]]; then
          p95_idx=$(( (count * 95 + 99) / 100 ))
          p95=$(echo "$durations" | sed -n "${p95_idx}p")
          safe_op=$(echo "$op" | tr '-' '_')
          echo "diag_${safe_op}_count=${count}"
          echo "diag_${safe_op}_p95_ms=${p95}"
        fi
      done

      echo "diag_metrics_total=${total_records}"
      echo "diag_metrics_failures=${failure_count}"
      echo "diag_metrics_retries=${retry_count}"
    fi
  } >> "$GITHUB_OUTPUT"
fi

# ---- 7. Emit annotation with compact metrics (visible via check-runs API) ----
prefetch_bytes_mib="n/a"
if [[ -n "${prefetch_bytes:-}" && "${prefetch_bytes:-0}" != "0" ]]; then
  prefetch_bytes_mib=$(awk -v b="$prefetch_bytes" 'BEGIN { printf "%.1f", b / 1048576 }')
fi

metrics_summary=""
if [[ -n "$metrics_jsonl" && -f "$metrics_jsonl" ]] && command -v jq &>/dev/null; then
  m_total=$(wc -l < "$metrics_jsonl" 2>/dev/null || echo "0")
  m_failures=$(jq -r 'select(.error != null or ((.status // 0) >= 500)) | .operation' "$metrics_jsonl" 2>/dev/null | wc -l || echo "0")

  check_p95=""
  dl_p95=""
  for op in cache_blobs_check cache_blobs_download_urls; do
    durations=$(jq -r "select(.operation == \"${op}\") | .duration_ms // empty" "$metrics_jsonl" 2>/dev/null | sort -n)
    count=$(echo "$durations" | grep -c . 2>/dev/null || echo "0")
    if [[ "$count" -gt 0 ]]; then
      p95_idx=$(( (count * 95 + 99) / 100 ))
      p95=$(echo "$durations" | sed -n "${p95_idx}p")
      if [[ "$op" == "cache_blobs_check" ]]; then
        check_p95="${count}reqs,p95=${p95}ms"
      else
        dl_p95="${count}reqs,p95=${p95}ms"
      fi
    fi
  done
  metrics_summary=" | requests=${m_total} failures=${m_failures} check=[${check_p95:-n/a}] download=[${dl_p95:-n/a}]"
fi

echo "::notice title=Proxy Diagnostics (${benchmark_id}/${phase})::index=${preload_entries:-0} prefetch_dl=${prefetch_downloaded:-0} prefetch_skip=${prefetch_skipped:-0} prefetch_fail=${prefetch_failed:-0} bytes=${prefetch_bytes_mib}MiB elapsed=${prefetch_elapsed:-?} errors=${error_count:-0}${metrics_summary}"
