# helix-nix: baseline-20261006-rolling-24

Question: Does Nix restore the Helix package closure on a fresh store?

Measured scope: Nix package derivation build or substitution after its build dependencies are realized; dependency preparation, output verification and provider post-step publication are outside the build timer. All workers import the same checksummed dependency-store export before timing; its derivation and NAR hashes must match, and the measured package is excluded from the seed.

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | BoringCache | 1 | 359.7369315835612 | 359.7369315835612–359.7369315835612 | unmeasured | 0 |
| Changed-source build | Cachix | 1 | 4.197131137084 | 4.197131137084–4.197131137084 | unmeasured | 0 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

Missing completion checks: 37429954604


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Changed-source build | 2.5616037845611572 | 357.17532779900006 | 359.7369315835612 | unmeasured | unmeasured | not reported | [JSON](runs/1-boringcache-commit.json) |
| 1 | Cachix | Changed-source build | 2.5315513610839844 | 1.6655797760000155 | 4.197131137084 | unmeasured | unmeasured | not reported | [JSON](runs/1-cachix-commit.json) |

[Full records and checks](report.json)
