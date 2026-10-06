# zed-nix: cadence-37429783479-27

Question: Does Nix restore the Zed package closure on a fresh store?

Measured scope: Nix package derivation build or substitution after its build dependencies are realized; dependency preparation, output verification and provider post-step publication are outside the build timer. All workers import the same checksummed dependency-store export before timing; its derivation and NAR hashes must match, and the measured package is excluded from the seed.

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | BoringCache | 1 | 2882.501230607906 | 2882.501230607906–2882.501230607906 | unmeasured | 0 |
| Warm build | BoringCache | 1 | 12.966068226898187 | 12.966068226898187–12.966068226898187 | 576291607 | 1 |
| Cold build | Cachix | 1 | 1926.9760789183588 | 1926.9760789183588–1926.9760789183588 | unmeasured | 0 |
| Warm build | Cachix | 1 | 8.46340837165235 | 8.46340837165235–8.46340837165235 | unmeasured | 0 |

Missing completion checks: 37429896983


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Cold build | 5.644976615905762 | 2876.8562539920003 | 2882.501230607906 | unmeasured | unmeasured | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 11.498345851898193 | 1.467722374999994 | 12.966068226898187 | 576291607 | boringcache-check | hit | [JSON](runs/1-boringcache-warm.json) |
| 1 | Cachix | Cold build | 2.4308958053588867 | 1924.545183113 | 1926.9760789183588 | unmeasured | unmeasured | miss | [JSON](runs/1-cachix-cold.json) |
| 1 | Cachix | Warm build | 3.5568466186523438 | 4.906561753000005 | 8.46340837165235 | unmeasured | unmeasured | hit | [JSON](runs/1-cachix-warm.json) |

[Full records and checks](report.json)
