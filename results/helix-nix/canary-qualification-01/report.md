# helix-nix: canary-qualification-01

Question: Does Nix restore the Helix package closure on a fresh store?

Measured scope: Nix package derivation build or substitution after its build dependencies are realized; dependency preparation, output verification and provider post-step publication are outside the build timer

Observations: 8/8 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | BoringCache | 2 | 300.72452188230534 | 240.000149676342–361.4488940882686 | unmeasured | 0 |
| Warm build | BoringCache | 2 | 6.814367409298967 | 5.505685232007409–8.123049586590525 | 46172357.0 | 2 |
| Cold build | Cachix | 2 | 325.39567017044965 | 283.539126630117–367.2522137107823 | unmeasured | 0 |
| Warm build | Cachix | 2 | 4.294964134722619 | 3.6862304045152428–4.903697864929995 | unmeasured | 0 |

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Cold build | 4.722970247268677 | 356.72592384099994 | 361.4488940882686 | unmeasured | unmeasured | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 7.594966411590576 | 0.5280831749999493 | 8.123049586590525 | 46172357 | boringcache-check | hit | [JSON](runs/1-boringcache-warm.json) |
| 1 | Cachix | Cold build | 2.3948261737823486 | 364.85738753699997 | 367.2522137107823 | unmeasured | unmeasured | miss | [JSON](runs/1-cachix-cold.json) |
| 1 | Cachix | Warm build | 2.797926187515259 | 0.888304216999984 | 3.6862304045152428 | unmeasured | unmeasured | hit | [JSON](runs/1-cachix-warm.json) |
| 2 | BoringCache | Cold build | 3.937563419342041 | 236.06258625699996 | 240.000149676342 | unmeasured | unmeasured | miss | [JSON](runs/2-boringcache-cold.json) |
| 2 | BoringCache | Warm build | 4.828489542007446 | 0.6771956899999623 | 5.505685232007409 | 46172357 | boringcache-check | hit | [JSON](runs/2-boringcache-warm.json) |
| 2 | Cachix | Cold build | 2.5683531761169434 | 280.97077345400004 | 283.539126630117 | unmeasured | unmeasured | miss | [JSON](runs/2-cachix-cold.json) |
| 2 | Cachix | Warm build | 3.0685791969299316 | 1.8351186680000637 | 4.903697864929995 | unmeasured | unmeasured | hit | [JSON](runs/2-cachix-warm.json) |

[Full records and checks](report.json)
