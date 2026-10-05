# Upstream recipe review, October 5

The hourly source check at [run 37315116759](https://github.com/boringcache/benchmarks/actions/runs/37315116759)
identified four recipe changes. These reviews approve the recipe definitions for
qualification; they do not establish that a new-source build or cache restore passed.

| Case | Reviewed candidate | Change and measurement impact |
| --- | --- | --- |
| Immich | `f938b2faa77cc25064c2ce54c956c40e4dd4ee79` | The Docker workflow adds a machine-learning OpenVINO runner mapping, outside the server workload. The server Dockerfile advances both pinned base images from 202609291109 to 202610021601. The server command and output check remain the same; new base images require a new build observation. |
| Qdrant | `48199a3c2d4156d0ab7e692f3925a9ed14059008` on `dev` | Integration jobs now download one shared debug binary and split consensus tests into shards. E2E jobs build one Docker image, export it to an artifact and load it on test workers. The Dockerfile and build arguments are unchanged. The benchmark retains local image loading and verification; artifact transfer and test sharding remain outside its build measurement. |
| msgpack | `ec75ffc01364adc6ea9b5f4d9129fd63602e6a45` | `project/build.properties` advances sbt 2.0.9 to 2.0.10. `build.sbt`, `project/plugins.sbt` and the launcher are unchanged. Native REAPI execution must be screened with the new sbt version. |
| Zed | `dff535449c663f3e2fde9256db2620c2ace2bc4c` | The release packaging script changes Sentry handling, linker flags and stripping of packaged copies. The rolling workload remains its declared `cargo build --release --locked`; it does not measure the release packaging script. The separately pinned release-layer plans and their recipe contract remain unchanged. |

Each contract contains the new reviewed file hashes. Its existing parent source
can still be verified using `upstream_files_by_revision`, keyed by its complete
commit SHA. That exception retains the same reviewed file set and does not apply
to other revisions. Source advancement still requires recipe verification; a
later change to any reviewed file blocks advancement again.

The Gogs rolling qualification also permits the exact historical parent
`103893ed5f78d2f138f5286a2dd3b4e94d18fb0b`. Its web manifest uses `@pierre/diffs`
1.2.3; the declared child advances it to 1.4.1 with matching lockfile updates.
The Moon build commands are unchanged. These are changed-source observations,
including changed dependencies, rather than identical-source replay observations.
