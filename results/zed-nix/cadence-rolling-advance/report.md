# zed-nix: cadence-rolling-advance

Question: Does Nix restore the Zed package closure on a fresh store?

Measured scope: Nix package derivation build or substitution after its build dependencies are realized; dependency preparation, output verification and provider post-step publication are outside the build timer. All workers import the same checksummed dependency-store export before timing; its derivation and NAR hashes must match, and the measured package is excluded from the seed.

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | BoringCache | 1 | 1872.8299867073292 | 1872.8299867073292–1872.8299867073292 | 576291607 | 1 |
| Changed-source build | Cachix | 1 | 1802.7406344062056 | 1802.7406344062056–1802.7406344062056 | unmeasured | 0 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Changed-source build | 7.843063831329346 | 1864.9869228759999 | 1872.8299867073292 | 576291607 | boringcache-check | not reported | [JSON](runs/1-boringcache-commit.json) |
| 1 | Cachix | Changed-source build | 2.1445672512054443 | 1800.5960671550001 | 1802.7406344062056 | unmeasured | unmeasured | not reported | [JSON](runs/1-cachix-commit.json) |

[Full records and checks](report.json)
