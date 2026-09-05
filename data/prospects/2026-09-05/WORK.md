# Prospect benchmark work

Scope: six upstream onboarding forks under `boringcache`, validation branches only. No issues, comments, PRs, releases, deployments, or upstream branch changes. Every cache uses the existing `boringcache/benchmarks` workspace. Preserve upstream product structure and checks.

## Checklist

- [x] Read benchmark and One Action guidelines and Stirling/Proteus prior art.
- [x] Verify the six upstream issues and create same-name forks.
- [x] Verify released OIDC connection and real publish/restore behavior; no static fallback needed.
- [x] Pin source, toolchain, Action distribution and workload for each comparison.
- [x] WaterUI: bounded Linux workspace nextest pass; Cargo reuse versus existing Rust cache. All-feature and doctest follow-ups are explicitly outside this comparison.
- [x] adorsys: real all-target/all-feature Cargo build, then compatible nextest work; account for the missing base-branch population separately.
- [x] Ferrum Edge: real unit-test compilation/execution; account for the deterministic wrapper fix separately from shared compiler storage.
- [x] Cadence: real CI Dockerfile and matching layer-cache baseline. In-container Go compilation is explicitly outside the measured workload.
- [x] dotCMS: Nx frontend build first; preserve existing Maven/S3 investment and do not conflate cache surfaces.
- [x] Loomarr: current four-ABI Android build and artifact checks; follow current upstream Gradle experiment and dependency policy.
- [x] Validate workflow/config syntax and review minimal diffs before publishing validation branches.
- [x] Run cold and exactly one dependent warm leg on separate standard runners for each provider; retain source, setup/build/total timing and product-emitted evidence.
- [ ] Download and summarize valid results, failures, and unavailable metrics honestly. Keep exact run links.
- [ ] Add a BoringCache rolling sequence for each prospect: seed at the third first-parent ancestor of the pinned upstream head, then build the three real successor commits serially, restoring and publishing one persistent cohort.
- [ ] Retain rolling results separately from fresh GitHub/BoringCache comparisons, with source ancestry and per-commit evidence.
- [ ] Publish the compact report, source/run manifests and summary data on the validation branch.
- [ ] Remove temporary downloads/scratch artifacts; retain only reproducible wiring and useful evidence.

## Decisions and findings

- Forks: `boringcache/waterui`, `boringcache/status-list-server`, `boringcache/ferrum-edge`, `boringcache/cadence`, `boringcache/core`, `boringcache/loomarr`.
- Reviewed One Action v1.20.2 resolves to `c62af42c5c1e29388ceeea77b6a7f1db51f641e7` and defaults to released CLI v1.20.3. Its shipped inputs no longer include `setup`; follow the actual shipped contract instead of copying the older skill example.
- WaterUI already split lint from tests after issue #328; benchmark the pinned current workload, not the obsolete 63–82 minute serial pipeline.
- OIDC support is shipped in the CLI; One Action's direct job/session activation requires checking before use.

## Cleanup ledger

- Initial installer/harness scratch files and temporary OIDC probe branch: removed.
- `/private/tmp/summarize-prospects.py`: remove after final result aggregation.
- Compact report files are staged as an uncommitted working draft in the validation worktree; refresh them from the evidence workspace after Ferrum finishes.
- Six `*-onboarding` checkouts: durable minimal validation checkouts, not build-output stores.

## Running comparisons

- Validation branches are published in all six forks. Shared harness is `boringcache/benchmarks` branch `prospect-validation`, isolated locally at `/Users/gaurav/boringcache/benchmarks-worktrees/prospect-validation`.
- OIDC enrollment and trusted publish policy passed on the WaterUI fork (33970798955) and central harness (33973917111); browser approvals selected only `boringcache/benchmarks`. No static tokens. Real cache writes/restores still require benchmark evidence.
- Initial comparisons: WaterUI 33973996116; adorsys 33973996178; Ferrum 33973996106; Cadence 33973996120; dotCMS 33973996156. Source pins are in harness `scripts/prospects/sources.json`.
- Cold/warm are separate fresh standard runners. GitHub caches use run-ID keys. BoringCache uses previously unseeded 20260905 project/lane tags; change tags if any failed cold attempt published compiler entries.
- Timing boundary: `measured_command_seconds` includes BoringCache adapter lifecycle; GitHub action cache restore/save is outside that command. Final comparisons must include cache action durations or whole job duration, with setup separately identified.
- Loomarr shellcheck/syntax and CI-impact fixture passed. Local full verification stopped on agent-harness lock fixture and GNU Make compatibility; Android Node contract test needed uninstalled frontend dependencies. Hosted setup runs affected contract tests on Linux before Android builds. No gates or ABI/artifact checks removed.
- Additional temporary files to remove: `/private/tmp/create-prospect-harness.py`, `/private/tmp/add-loomarr-harness.py`, harness `scripts/prospects/__pycache__`.

## First evidence review

- Cadence completed all four jobs successfully. BoringCache OIDC performed real publication and fresh-runner remote restore. Command cold/warm 100.785s/58.500s; GitHub GHA 169.818s/66.196s. Whole jobs 113s/69s versus 189s/88s. These are single samples, with image loading dominating warm time; not Go test compilation savings.
- dotCMS BoringCache warm completed with Nx reporting 18/19 tasks from cache, command 17.505s. GitHub archive restored but Nx 23.1.1 reported Unrecognized Cache Artifacts and rebuilt; exclude that warm row from head-to-head speedup claims. Pinned Nx source keys its SQLite metadata by machine ID. Do not bypass the trust guard or pretend this is a valid warm cache.
- Local cache inspect had no configured credential. This is unavailable storage evidence, not zero bytes. No local token created because CI OIDC is working.
- Loomarr hosted Linux contract tests passed and both real Android builds started.

- adorsys all four jobs passed, all 324 tests each. Warm whole-job 188s BoringCache versus 314s GitHub, valid restores both; BoringCache kept full Cargo state while rust-cache rebuilt for 2m46s. Do not call this a raw network-speed comparison.
- Fork audit found three automatic Dependabot PRs created by the organization security policy immediately after fork creation: status-list-server #1, cadence #1, core #1. Closed all three without comments. The organization enforces security updates (HTTP 422 prevents repository-level disabling); no organization policy was changed. No benchmark PRs or upstream PRs were created.
- Native cache inventory via OIDC succeeded (33974912140). Archive payload sizes are available; added public prefix-filtered tag queries for compiler/task-store coverage.

## Ferrum follow-up

- Initial cold tests passed on both providers. BoringCache emitted `Cargo target save skipped: the wrapped command changed the source checkout`; only registry and compiler state were published. Cancelled the remaining initial warm jobs once this was identified. Preserve run 33973996106 as investigation-only, not the final Cargo comparison.
- Minimal correction: `.boringcache.toml` caches `cargo test --lib --test unit_tests --no-run`, then the harness executes the identical test command after cache publication. Capture git status after compilation and after tests, plus any tracked diff. New r2 tags keep the next cold cohort unseeded.
- 1Password's signing helper repeatedly failed. The fork update was committed through the authorized GitHub Contents API (57f9940f, unsigned). The central harness commit uses the existing SSH-agent key through standard ssh-keygen and remains signed (0d3ece53). GitHub GraphQL commit mutation lacked permission and made no change. No signing checks were disabled or organization permissions changed.
- Read-only configured production MCP bridge returned `Production MCP request failed` during initialization; using public CLI OIDC inventory and retained product evidence instead. Archive tag listing does not include native compiler/task storage, so do not interpret missing tag rows as zero bytes.

- WaterUI and Loomarr completed all four jobs with valid warm reuse. Whole-job warm WaterUI: BoringCache 679s vs GitHub 666s; Loomarr: 1564s vs 1484s. Preserve these neutral/negative results and their scope; no speedup claim.
- Corrected Ferrum fresh run: 33981755862, source 57f9940f, harness 0d3ece53, fresh r2 tags.
- Inventory run 33981755831 failed because `status --limit 100` exceeds the public 1–10 limit, not because of OIDC permissions. Corrected to 10 and retained sessions at 50.
- Cleanup: removed the three initial scratch files, empty failed local inspect output and remote WaterUI OIDC probe branch. `/private/tmp/summarize-prospects.py` is the remaining owned reporting scratch script; remove after the final results update.

- Final scope audit: all six validation checkouts are clean, match the source manifest, and use `boringcache/benchmarks`; no open PRs exist in any of the six forks. Five patches are cache configuration only; Loomarr is 37 additions/1 deletion across its opt-in integration, design note and CI-impact coverage. Updated inventory workflow passes actionlint. Cadence logs confirm all four builds resolved the same golang base-image digest.

- Corrected Ferrum GitHub cold passed all 24,049 tests with 10 existing ignored tests. Retained diagnostics show an empty checkout status after compilation and only untracked `ferrum-managed-tls/` after tests; tracked diff is empty. This identifies test side effects without bypassing the Cargo source-change guard.

- Public OIDC inventory 33983636386 confirms the corrected Ferrum target is ready (1,324,424,341 compressed bytes, published 18:02:38 UTC) with registry 128,132,292 bytes. Session page now retains all 74 rows without truncation. The BoringCache cold command continues after publication; final logs will separate remaining work.

- Ferrum r2 source-change correction published target successfully. A second setup issue was identified: the adapter defaults `CC`/`CXX` to sccache wrappers, while the later bare test command inherited unset values. Logs confirm a second 15m45s compilation after the 19m21s cached compilation and successful save. Cancelled this investigation run; preserved logs and publication evidence. New r3 workflow explicitly sets identical CC, CXX and CARGO_TARGET_DIR throughout all four jobs, with fresh tags and source 91e334abb107c8cda52858929fcb2ec30b568960. Final comparison run 33983928426; harness 69123a5d48a505df1429ca610442419759ce1af8.

- Source-pin guard stopped run 33983928426 before compilation because four literal checkout refs still pointed at the prior source. Corrected the refs and verified every one of the 24 prospect checkout refs against the manifest using YAML parsing. Tags remained unseeded. Active corrected run: 33984066894, harness dc2d829e6735281bb699c0918898b790817c4e3a.

- Completed-case data audit passed: five cases each have exactly four matching source records, provider/phase pairs, consistent cache-inclusive versus whole-job timing boundaries, retained artifacts, and read-only BoringCache warm evidence. Final Ferrum remains pending.

- User requested Deno/Zed guidance review. Local clones were behind, so reviewed current remote commits: Deno 665fcb2f1453120c9d5429d8f481ce25e67e888d; Zed 19c2b8b939628d3838ed4327bf07146b5689714d. Both run direct Cargo, not Docker. Zed explicitly configures compiler-cache=sccache and stable CC/CXX, with a separate target-only/compiler-only/combined adjacent-commit matrix. Our bounded same-commit combined-product scope and its attribution limits are explicit in the report. Existing Deno/Zed checkouts were not changed.

- User clarified their usual benchmark method: seed from three or five commits back and roll each real commit in order. Selected three commits back (four builds per prospect), following the existing BoringCache-only Deno/Zed rolling chain. Preserve all current paired fresh results. Rolling jobs will publish after every successful build and use a separate persistent cohort; no synthetic mutations, upstream changes, comments or PRs.

- All six boringcache-rolling-validation branches are pushed. Each has one minimal integration commit at the third first-parent ancestor, followed by three real upstream deltas. Every snapshot differs from its mapped upstream only in the reviewed integration files; fresh validation checkouts were restored. Central rolling-sources.json records all 24 source mappings and changed upstream files. Six four-job rolling workflows plus source ancestry checks passed actionlint/Ruff and explicit SHA/dependency validation.
- Additional owned scratch for final cleanup: /private/tmp/prepare-prospect-rolling.py and /private/tmp/add-prospect-rolling.py.

- Rolling workflows dispatched from signed harness 4f1bc59bb26281cabbbfe391149d2cf57ea7bd12. Run IDs are in runs.json. Independent Loomarr review found no issues in the exact four source snapshots, native gate preservation, serial dependencies, or index-zero publication; reviewer did not execute builds/tests/lint. Root syntax/source/dependency checks passed.

- Added owned artifact-collection scratch /private/tmp/collect-prospect-run.py; remove after final collection. It retains raw artifacts and complete compressed workflow logs without parsing product internals.

- Rolling Cadence and dotCMS completed all four jobs successfully. Preserved raw evidence and log ZIPs; report separates their unchanged image/frontend input scope from code-invalidation claims. Ferrum r3 cold passed all 24,049 tests, published target, and reused compilation in 1.53s at test handoff; duplicate compilation is fixed. Both warm jobs remain active.

- Inventory workflow now retains a 24h window with two native session pages; 33986564351 passed and returned all 134 rows. Final inventory is still required after rolling completion. New reporting scratch /private/tmp/refresh-prospect-report.py updates only the rolling table from recorded job data; remove at final cleanup.

- adorsys rolling commit 1 passed and rebuilt the application crate after a real src/config.rs change accompanying the Helm work (corrected an earlier Helm-only interpretation). Commit 2 changes Dockerfile only and reused compilation in 0.53s; all 324 tests passed.

- All six fresh comparisons are complete: 24 successful jobs on matching source pins, including read-only BoringCache warm legs. Ferrum warm whole-job 530s versus GitHub 1564s; all 24,049 tests passed each job. Higher BoringCache cold cost and observed test-time variance are retained. The full fresh result/source/timing/evidence audit passed. Rolling adorsys also completed all four jobs; WaterUI, Ferrum and Loomarr remain active.
