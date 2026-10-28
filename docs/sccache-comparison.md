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

```sh
gh workflow run project.yml --ref sccache-comparison \
  -f tool=Rust/Cargo -f project=cargo/zed -f mode=fresh \
  -f lane='boringcache-sccache-017 boringcache-sccache-018 boringcache-sccache-019' \
  -f cli=v1.45.0
```

Branch runs upload artifacts without publishing results to `main`. Experimental
lanes are excluded from the public report. One sample per version is a screening
comparison and does not establish repeatable performance differences.
