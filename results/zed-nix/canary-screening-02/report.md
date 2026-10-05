# zed-nix: canary-screening-02

Question: Does Nix restore the Zed package closure on a fresh store?

Measured scope: Nix package derivation build or substitution after its build dependencies are realized; dependency preparation, output verification and provider post-step publication are outside the build timer

Observations: 2/4 recorded; 0 failed; 2 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | BoringCache | 1 | 2788.14372093361 | 2788.14372093361–2788.14372093361 | unmeasured | 0 |
| Cold build | Cachix | 1 | 2996.7530764946086 | 2996.7530764946086–2996.7530764946086 | unmeasured | 0 |

Run 37296214039 failed completion checks:

- Workflow concluded failure
- cachix zed-nix warm: failure
- boringcache zed-nix warm: failure

Missing observations:

- Sample 1, BoringCache, Warm build
- Sample 1, Cachix, Warm build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Cold build | 2.3193912506103516 | 2785.8243296829996 | 2788.14372093361 | unmeasured | unmeasured | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | Cachix | Cold build | 2.6468822956085205 | 2994.106194199 | 2996.7530764946086 | unmeasured | unmeasured | miss | [JSON](runs/1-cachix-cold.json) |

[Full records and checks](report.json)
