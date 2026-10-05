# helix-nix: cadence-fresh-01

Question: Does Nix restore the Helix package closure on a fresh store?

Measured scope: Nix package derivation build or substitution after its build dependencies are realized; dependency preparation, output verification and provider post-step publication are outside the build timer. All workers import the same checksummed dependency-store export before timing; its derivation and NAR hashes must match, and the measured package is excluded from the seed.

Observations: 4/8 recorded; 0 failed; 4 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | BoringCache | 1 | 219.9609663066821 | 219.9609663066821–219.9609663066821 | unmeasured | 0 |
| Warm build | BoringCache | 1 | 6.481956831083494 | 6.481956831083494–6.481956831083494 | 46171613 | 1 |
| Cold build | Cachix | 1 | 363.82386535294876 | 363.82386535294876–363.82386535294876 | unmeasured | 0 |
| Warm build | Cachix | 1 | 3.6484187521867284 | 3.6484187521867284–3.6484187521867284 | unmeasured | 0 |

Missing observations:

- Sample 2, BoringCache, Cold build
- Sample 2, Cachix, Cold build
- Sample 2, BoringCache, Warm build
- Sample 2, Cachix, Warm build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Cold build | 4.364945411682129 | 215.59602089499998 | 219.9609663066821 | unmeasured | unmeasured | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 5.811720848083496 | 0.6702359829999978 | 6.481956831083494 | 46171613 | boringcache-check | hit | [JSON](runs/1-boringcache-warm.json) |
| 1 | Cachix | Cold build | 2.4744367599487305 | 361.349428593 | 363.82386535294876 | unmeasured | unmeasured | miss | [JSON](runs/1-cachix-cold.json) |
| 1 | Cachix | Warm build | 2.3420071601867676 | 1.3064115919999608 | 3.6484187521867284 | unmeasured | unmeasured | hit | [JSON](runs/1-cachix-warm.json) |

[Full records and checks](report.json)
