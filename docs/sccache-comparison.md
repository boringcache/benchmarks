# Sccache version comparison

| Setting | Value |
|---|---|
| Case | `cargo/zed` |
| Source | `40180d9c40e2d20eb63d388bff920818f2910b53` |
| Rust | `1.98.1` |
| BoringCache | `1.45.0` |
| Sccache | `0.17.0`, `0.18.0`, `0.19.0` |
| Runner | GitHub `ubuntu-24.04`, 4 cores |
| Build | `cargo build --release --locked` |
| Phases | Cold, then identical-source warm on a separate runner |
| Cache | Existing Cargo plus plan, separate fresh scope per version |
| Memory evidence | Process RSS, available RAM and swap sampled every five seconds |

The experimental lanes use the existing BoringCache Cargo plus setup.
[Mise version overrides](https://mise.jdx.dev/configuration.html)
select sccache before installation. Preparation checks the installed version.
The sampler records observed RSS maxima; it does not measure exact process
high-water marks between samples. Each job retains its machine description,
samples, build log and result. Failed phases remain part of the comparison.
The build step also streams machine details and samples into its job log,
so readings already received by GitHub remain available if the runner stops
before it can upload diagnostics. Build exit status is preserved.

```sh
gh workflow run project.yml --ref sccache-comparison \
  -f tool=Rust/Cargo -f project=cargo/zed -f mode=fresh \
  -f lane='boringcache-sccache-017 boringcache-sccache-018 boringcache-sccache-019' \
  -f cli=v1.45.0
```

Branch runs upload artifacts without publishing results to `main`. Experimental
lanes are excluded from the public report. One sample per version is a screening
comparison and does not establish repeatable performance differences.

The 0.18.0 and 0.19.0 cold jobs in [run 40670513475](https://github.com/boringcache/benchmarks/actions/runs/40670513475)
ended after runner shutdown signals at 10:48:34 and 10:55:10 UTC on October 28.
Diagnostics upload was skipped, so those attempts have no retained memory
samples. Both cancelled attempts are preserved. Follow-ups use the same source,
tools and runner with the added live memory log. Each follow-up version gets a separate workflow:

```sh
for lane in boringcache-sccache-018 boringcache-sccache-019; do
  gh workflow run project.yml --ref sccache-comparison \
    -f tool=Rust/Cargo -f project=cargo/zed -f mode=fresh \
    -f lane="$lane" -f cli=v1.45.0
done
```

The 0.17.0 cold job in the initial comparison passed. All three warm jobs started;
the 0.18.0 and 0.19.0 warm jobs therefore follow interrupted cold builds.

A separate experimental lane, `boringcache-sccache-019-client`, sets
`SCCACHE_CLIENT_SIDE=1`. [Sccache 0.19.0 documents this mode](https://github.com/mozilla/sccache/blob/v0.19.0/docs/Architecture.md#client-side-mode-sccache_client_side):
the invoking process runs the compile pipeline while the daemon handles cache
storage and statistics. Source, tool versions, runner, build command and cache
plan match the 0.19.0 server-mode lane. Preparation rejects `SCCACHE_ERROR_LOG`,
which would cause sccache to ignore client-side mode. No distributed compiler
scheduler is configured. This comparison tests execution mode; it does not
assume that client-side mode reduces memory use.

```sh
gh workflow run project.yml --ref sccache-comparison \
  -f tool=Rust/Cargo -f project=cargo/zed -f mode=fresh \
  -f lane=boringcache-sccache-019-client -f cli=v1.45.0
```
