# zed-nix: cadence-fresh-01

Question: Does Nix restore the Zed package closure on a fresh store?

Measured scope: Nix package derivation build or substitution after its build dependencies are realized; dependency preparation, output verification and provider post-step publication are outside the build timer. All workers import the same checksummed dependency-store export before timing; its derivation and NAR hashes must match, and the measured package is excluded from the seed.

Observations: 8/8 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | BoringCache | 2 | 2823.3084382041816 | 2792.4297531088596–2854.1871232995036 | unmeasured | 0 |
| Warm build | BoringCache | 2 | 9.83641568732537 | 8.955559792726945–10.717271581923796 | 576291607.0 | 2 |
| Cold build | Cachix | 2 | 2839.42401810587 | 2830.319037953921–2848.528998257819 | unmeasured | 0 |
| Warm build | Cachix | 2 | 5.50904610590473 | 4.8552112620657795–6.1628809497436805 | unmeasured | 0 |

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Cold build | 3.01418137550354 | 2851.172941924 | 2854.1871232995036 | unmeasured | unmeasured | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 9.198845624923706 | 1.5184259570000904 | 10.717271581923796 | 576291607 | boringcache-check | hit | [JSON](runs/1-boringcache-warm.json) |
| 1 | Cachix | Cold build | 2.9721765518188477 | 2845.556821706 | 2848.528998257819 | unmeasured | unmeasured | miss | [JSON](runs/1-cachix-cold.json) |
| 1 | Cachix | Warm build | 2.497649908065796 | 2.3575613539999836 | 4.8552112620657795 | unmeasured | unmeasured | hit | [JSON](runs/1-cachix-warm.json) |
| 2 | BoringCache | Cold build | 4.295579671859741 | 2788.134173437 | 2792.4297531088596 | unmeasured | unmeasured | miss | [JSON](runs/2-boringcache-cold.json) |
| 2 | BoringCache | Warm build | 7.493867635726929 | 1.4616921570000159 | 8.955559792726945 | 576291607 | boringcache-check | hit | [JSON](runs/2-boringcache-warm.json) |
| 2 | Cachix | Cold build | 2.5098493099212646 | 2827.8091886439997 | 2830.319037953921 | unmeasured | unmeasured | miss | [JSON](runs/2-cachix-cold.json) |
| 2 | Cachix | Warm build | 2.8624181747436523 | 3.300462775000028 | 6.1628809497436805 | unmeasured | unmeasured | hit | [JSON](runs/2-cachix-warm.json) |

[Full records and checks](report.json)
