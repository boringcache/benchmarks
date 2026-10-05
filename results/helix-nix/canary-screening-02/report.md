# helix-nix: canary-screening-02

Question: Does Nix restore the Helix package closure on a fresh store?

Measured scope: Nix package derivation build or substitution after its build dependencies are realized; dependency preparation, output verification and provider post-step publication are outside the build timer

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | BoringCache | 1 | 296.34937598663436 | 296.34937598663436–296.34937598663436 | unmeasured | 0 |
| Warm build | BoringCache | 1 | 5.810530557688935 | 5.810530557688935–5.810530557688935 | 46172357 | 1 |
| Cold build | Cachix | 1 | 360.6637888889659 | 360.6637888889659–360.6637888889659 | unmeasured | 0 |
| Warm build | Cachix | 1 | 4.730110110390228 | 4.730110110390228–4.730110110390228 | unmeasured | 0 |

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Cold build | 3.5654776096343994 | 292.78389837699996 | 296.34937598663436 | unmeasured | unmeasured | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 5.180853843688965 | 0.6296767139999702 | 5.810530557688935 | 46172357 | boringcache-check | hit | [JSON](runs/1-boringcache-warm.json) |
| 1 | Cachix | Cold build | 2.7561771869659424 | 357.90761170199994 | 360.6637888889659 | unmeasured | unmeasured | miss | [JSON](runs/1-cachix-cold.json) |
| 1 | Cachix | Warm build | 2.3965330123901367 | 2.3335770980000916 | 4.730110110390228 | unmeasured | unmeasured | hit | [JSON](runs/1-cachix-warm.json) |

[Full records and checks](report.json)
