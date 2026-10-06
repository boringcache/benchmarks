# Upstream recipe review: October 6

Recipe exceptions apply to exact commits. The source controller still rejects
unreviewed recipe changes. Existing pins and historical observations are retained.

| Case | Reviewed candidate | Change | Measured workload |
| --- | --- | --- | --- |
| Qdrant | `191e255362fe3f985979e094095104f49ddf15a4` | Docker builder changes Rust 1.98.1 to 1.99.0. Integration tests split into separate jobs and share build artifacts; feature selection is unchanged. | Both providers use the candidate Dockerfile with the existing CI profile and declared feature projection. Image inspection remains required. |
| Zed Cargo rolling | `2239fa76b1f32b4f1ea46687bcd2cf6961b7082a` | Bundle script adds explicit Sentry policy, requires a supported LLD, uses safe ICF for the editor, and strips packaging copies instead of Cargo outputs. Rust toolchain file is unchanged. | The rolling plan measures plain `cargo build --release --locked` and verifies the editor executable. It does not execute or qualify the changed release packaging script. The older release-layer experiment retains its separate source pair and recipe contract. |
| Zed Nix | `2239fa76b1f32b4f1ea46687bcd2cf6961b7082a` | Updates pinned nixpkgs; disables incompatible cargo-about build features; uses nixpkgs' LiveKit WebRTC with explicit Linux library search path. | Both providers use the candidate flake and one common dependency export. Exact package and dependency checks remain required. New dependency/output paths do not inherit an older fresh series. |

Storybook uses upstream `3c97d29c70d3215aab512e678d9c8567356cabd3`.
Its native Nx variant runs production compilation for React Vite and its declared
upstream dependencies. Local installation, compile and output checks passed.
The archive sandbox remains a distinct workload. The disposable checkout removes
Nx Cloud binding and the legacy `codexCacheBust` marker before either comparison.

These reviews permit source inspection and new correctness screens. They do not
establish hosted build success or a performance claim for the candidates.
