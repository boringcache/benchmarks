# zed-nix: baseline-20261006-rolling-25

Question: Does Nix restore the Zed package closure on a fresh store?

Measured scope: Nix package derivation build or substitution after its build dependencies are realized; dependency preparation, output verification and provider post-step publication are outside the build timer. All workers import the same checksummed dependency-store export before timing; its derivation and NAR hashes must match, and the measured package is excluded from the seed.

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | BoringCache | 1 | 2833.234750368144 | 2833.234750368144–2833.234750368144 | unmeasured | 0 |
| Changed-source build | Cachix | 1 | 5.084782681776119 | 5.084782681776119–5.084782681776119 | unmeasured | 0 |

Comparison checks:

- Measured package cache states differ: BoringCache built the package (0 hits, 711 misses); Cachix substituted the exact package output.
- Rolling seed and changed-source sequence are unverified.

Missing completion checks: 37429957363


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Changed-source build | 5.250828266143799 | 2827.983922102 | 2833.234750368144 | unmeasured | unmeasured | not reported | [JSON](runs/1-boringcache-commit.json) |
| 1 | Cachix | Changed-source build | 2.388373851776123 | 2.6964088299999958 | 5.084782681776119 | unmeasured | unmeasured | not reported | [JSON](runs/1-cachix-commit.json) |

[Full records and checks](report.json)
