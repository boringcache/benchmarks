# zed-nix: cadence-rolling-seed

Question: Does Nix restore the Zed package closure on a fresh store?

Measured scope: Nix package derivation build or substitution after its build dependencies are realized; dependency preparation, output verification and provider post-step publication are outside the build timer. All workers import the same checksummed dependency-store export before timing; its derivation and NAR hashes must match, and the measured package is excluded from the seed.

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | BoringCache | 1 | 2834.6952709450306 | 2834.6952709450306–2834.6952709450306 | unmeasured | 0 |
| Changed-source build | Cachix | 1 | 7.971168194222969 | 7.971168194222969–7.971168194222969 | unmeasured | 0 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Changed-source build | 5.5863049030303955 | 2829.1089660420002 | 2834.6952709450306 | unmeasured | unmeasured | not reported | [JSON](runs/1-boringcache-commit.json) |
| 1 | Cachix | Changed-source build | 2.1795594692230225 | 5.791608724999946 | 7.971168194222969 | unmeasured | unmeasured | not reported | [JSON](runs/1-cachix-commit.json) |

[Full records and checks](report.json)
