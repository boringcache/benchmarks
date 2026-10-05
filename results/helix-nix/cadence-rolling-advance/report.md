# helix-nix: cadence-rolling-advance

Question: Does Nix restore the Helix package closure on a fresh store?

Measured scope: Nix package derivation build or substitution after its build dependencies are realized; dependency preparation, output verification and provider post-step publication are outside the build timer. All workers import the same checksummed dependency-store export before timing; its derivation and NAR hashes must match, and the measured package is excluded from the seed.

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | BoringCache | 1 | 295.80389107529044 | 295.80389107529044–295.80389107529044 | 46171799 | 1 |
| Changed-source build | Cachix | 1 | 3.877758286099265 | 3.877758286099265–3.877758286099265 | unmeasured | 0 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Changed-source build | 6.215389013290405 | 289.58850206200003 | 295.80389107529044 | 46171799 | boringcache-check | not reported | [JSON](runs/1-boringcache-commit.json) |
| 1 | Cachix | Changed-source build | 2.420297861099243 | 1.457460425000022 | 3.877758286099265 | unmeasured | unmeasured | not reported | [JSON](runs/1-cachix-commit.json) |

[Full records and checks](report.json)
