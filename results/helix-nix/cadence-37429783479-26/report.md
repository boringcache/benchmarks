# helix-nix: cadence-37429783479-26

Question: Does Nix restore the Helix package closure on a fresh store?

Measured scope: Nix package derivation build or substitution after its build dependencies are realized; dependency preparation, output verification and provider post-step publication are outside the build timer. All workers import the same checksummed dependency-store export before timing; its derivation and NAR hashes must match, and the measured package is excluded from the seed.

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | BoringCache | 1 | 228.66361673706893 | 228.66361673706893–228.66361673706893 | unmeasured | 0 |
| Warm build | BoringCache | 1 | 7.59505368521252 | 7.59505368521252–7.59505368521252 | 46171613 | 1 |
| Cold build | Cachix | 1 | 231.63236178039568 | 231.63236178039568–231.63236178039568 | unmeasured | 0 |
| Warm build | Cachix | 1 | 3.877311976055978 | 3.877311976055978–3.877311976055978 | unmeasured | 0 |

Missing completion checks: 37429886833


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Cold build | 3.7126810550689697 | 224.95093568199997 | 228.66361673706893 | unmeasured | unmeasured | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 7.114336252212524 | 0.48071743299999525 | 7.59505368521252 | 46171613 | boringcache-check | hit | [JSON](runs/1-boringcache-warm.json) |
| 1 | Cachix | Cold build | 2.15234112739563 | 229.48002065300005 | 231.63236178039568 | unmeasured | unmeasured | miss | [JSON](runs/1-cachix-cold.json) |
| 1 | Cachix | Warm build | 2.5873677730560303 | 1.2899442029999477 | 3.877311976055978 | unmeasured | unmeasured | hit | [JSON](runs/1-cachix-warm.json) |

[Full records and checks](report.json)
