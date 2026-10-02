# Historical website benchmark evidence

This report preserves the website's ten reviewed evidence summaries in [the source data](evidence.json). Measurements and product versions are copied without recalculation. These are historical observations, not results from the consolidated executor or qualification of the current product.

The [evidence archive](https://github.com/boringcache/benchmarks/releases/tag/evidence-website-runs-2026-10-02) contains 52 website-linked run exports: 51 complete scoped exports and one partial Hugo Go export whose logs are unavailable. The uploaded bundle was independently downloaded, checked against its SHA-256, extracted, and verified against each export's inventory. Preservation does not establish that every historical claim has a complete experimental design.

Bundle SHA-256: `17e8454a83b9baa1344addbd18391b954400fc44dbe446784a4b2bdbb589c720`. [The inventory](../../migration/website-evidence.json) identifies each original run, export directory, checksum, and gap.

Each summary below has a stable heading for its website evidence link. Original Actions URLs remain provenance. Queueing and unrelated setup must not be inferred as build time; provider-reported storage counts do not establish equivalent physical or billable storage. Missing evidence remains missing.

## mastodon-no-layer-reuse

Evidence kind: `paired_timing_series`.

Original presentation source: [https://github.com/boringcache/mastodon/actions/runs/31704136355](https://github.com/boringcache/mastodon/actions/runs/31704136355).

### Observation 1

Original execution: [boringcache/mastodon run 31702508770](https://github.com/boringcache/mastodon/actions/runs/31702508770).

Export: **complete**, 7 listed files, archive directory `mastodon/31702508770`.

| Field | Recorded value |
| --- | --- |
| project | mastodon/mastodon |
| tool | Docker · no layer hits |
| tool_page_slug | docker-build-cache |
| before_seconds | 536 |
| after_seconds | 175 |
| comparator | cache:false |
| scenario | Translation update · linux/amd64 |
| product_refs.cli_version | v1.19.1 |
| product_refs.action_ref | boringcache/one@e24257b122813ad11d53b9ed024b474ca4946ad2 |

### Observation 2

Original execution: [boringcache/mastodon run 31702508770](https://github.com/boringcache/mastodon/actions/runs/31702508770).

Export: **complete**, 7 listed files, archive directory `mastodon/31702508770`.

| Field | Recorded value |
| --- | --- |
| project | mastodon/mastodon |
| tool | Docker · no layer hits |
| tool_page_slug | docker-build-cache |
| before_seconds | 363 |
| after_seconds | 147 |
| comparator | cache:false |
| scenario | Translation update · linux/arm64 |
| product_refs.cli_version | v1.19.1 |
| product_refs.action_ref | boringcache/one@e24257b122813ad11d53b9ed024b474ca4946ad2 |

### Observation 3

Original execution: [boringcache/mastodon run 31703348790](https://github.com/boringcache/mastodon/actions/runs/31703348790).

Export: **complete**, 7 listed files, archive directory `mastodon/31703348790`.

| Field | Recorded value |
| --- | --- |
| project | mastodon/mastodon |
| tool | Docker · no layer hits |
| tool_page_slug | docker-build-cache |
| before_seconds | 518 |
| after_seconds | 175 |
| comparator | cache:false |
| scenario | Ruby task update · linux/amd64 |
| product_refs.cli_version | v1.19.1 |
| product_refs.action_ref | boringcache/one@e24257b122813ad11d53b9ed024b474ca4946ad2 |

### Observation 4

Original execution: [boringcache/mastodon run 31703348790](https://github.com/boringcache/mastodon/actions/runs/31703348790).

Export: **complete**, 7 listed files, archive directory `mastodon/31703348790`.

| Field | Recorded value |
| --- | --- |
| project | mastodon/mastodon |
| tool | Docker · no layer hits |
| tool_page_slug | docker-build-cache |
| before_seconds | 389 |
| after_seconds | 129 |
| comparator | cache:false |
| scenario | Ruby task update · linux/arm64 |
| product_refs.cli_version | v1.19.1 |
| product_refs.action_ref | boringcache/one@e24257b122813ad11d53b9ed024b474ca4946ad2 |

### Observation 5

Original execution: [boringcache/mastodon run 31704136355](https://github.com/boringcache/mastodon/actions/runs/31704136355).

Export: **complete**, 7 listed files, archive directory `mastodon/31704136355`.

| Field | Recorded value |
| --- | --- |
| project | mastodon/mastodon |
| tool | Docker · no layer hits |
| tool_page_slug | docker-build-cache |
| before_seconds | 536 |
| after_seconds | 191 |
| comparator | cache:false |
| scenario | Poll-duration redesign · linux/amd64 |
| product_refs.cli_version | v1.19.1 |
| product_refs.action_ref | boringcache/one@e24257b122813ad11d53b9ed024b474ca4946ad2 |

### Observation 6

Original execution: [boringcache/mastodon run 31704136355](https://github.com/boringcache/mastodon/actions/runs/31704136355).

Export: **complete**, 7 listed files, archive directory `mastodon/31704136355`.

| Field | Recorded value |
| --- | --- |
| feature_rank | 1 |
| project | mastodon/mastodon |
| tool | Docker · no layer hits |
| tool_page_slug | docker-build-cache |
| before_seconds | 380 |
| after_seconds | 134 |
| comparator | cache:false |
| scenario | Poll-duration redesign · linux/arm64 |
| product_refs.cli_version | v1.19.1 |
| product_refs.action_ref | boringcache/one@e24257b122813ad11d53b9ed024b474ca4946ad2 |

## docker-speed

Evidence kind: `paired_timing_range`.

Original presentation source: [https://github.com/boringcache/benchmarks/tree/076f3d1ce82b30a33b39decf8e554bb99e32d7f3](https://github.com/boringcache/benchmarks/tree/076f3d1ce82b30a33b39decf8e554bb99e32d7f3).

### Observation 1

Original execution: [boringcache/benchmark-hugo run 31569885431](https://github.com/boringcache/benchmark-hugo/actions/runs/31569885431).

Export: **complete**, 13 listed files, archive directory `benchmark-hugo/31569885431`.

| Field | Recorded value |
| --- | --- |
| before_seconds | 257 |
| after_seconds | 230 |
| product_refs.cli_version | v1.19.0 |
| product_refs.action_ref | boringcache/one@1d01e5dbf19ce259f921aa353d5e3e4ac5f942e4 |

### Observation 2

Original execution: [boringcache/benchmark-immich run 31569890271](https://github.com/boringcache/benchmark-immich/actions/runs/31569890271).

Export: **complete**, 13 listed files, archive directory `benchmark-immich/31569890271`.

| Field | Recorded value |
| --- | --- |
| feature_rank | 3 |
| project | immich-app/immich |
| tool | Docker |
| tool_page_slug | docker-build-cache |
| before_seconds | 443 |
| after_seconds | 204 |
| product_refs.cli_version | v1.19.0 |
| product_refs.action_ref | boringcache/one@1d01e5dbf19ce259f921aa353d5e3e4ac5f942e4 |

### Observation 3

Original execution: [boringcache/benchmark-posthog run 31569900357](https://github.com/boringcache/benchmark-posthog/actions/runs/31569900357).

Export: **complete**, 16 listed files, archive directory `benchmark-posthog/31569900357`.

| Field | Recorded value |
| --- | --- |
| feature_rank | 2 |
| project | posthog/posthog |
| tool | Docker |
| tool_page_slug | docker-build-cache |
| before_seconds | 2204 |
| after_seconds | 871 |
| product_refs.cli_version | v1.19.0 |
| product_refs.action_ref | boringcache/one@1d01e5dbf19ce259f921aa353d5e3e4ac5f942e4 |

### Observation 4

Original execution: [boringcache/benchmark-linkerd2 run 31569891810](https://github.com/boringcache/benchmark-linkerd2/actions/runs/31569891810).

Export: **complete**, 13 listed files, archive directory `benchmark-linkerd2/31569891810`.

| Field | Recorded value |
| --- | --- |
| before_seconds | 13 |
| after_seconds | 8 |
| product_refs.cli_version | v1.19.0 |
| product_refs.action_ref | boringcache/one@1d01e5dbf19ce259f921aa353d5e3e4ac5f942e4 |

### Observation 5

Original execution: [boringcache/benchmark-qdrant run 31569902388](https://github.com/boringcache/benchmark-qdrant/actions/runs/31569902388).

Export: **complete**, 13 listed files, archive directory `benchmark-qdrant/31569902388`.

| Field | Recorded value |
| --- | --- |
| before_seconds | 887 |
| after_seconds | 577 |
| product_refs.cli_version | v1.19.0 |
| product_refs.action_ref | boringcache/one@1d01e5dbf19ce259f921aa353d5e3e4ac5f942e4 |

### Observation 6

Original execution: [boringcache/benchmark-chroma run 31355272642](https://github.com/boringcache/benchmark-chroma/actions/runs/31355272642).

Export: **complete**, 13 listed files, archive directory `benchmark-chroma/31355272642`.

| Field | Recorded value |
| --- | --- |
| before_seconds | 1507 |
| after_seconds | 973 |
| product_refs.cli_version | v1.18.0 |
| product_refs.action_ref | boringcache/one@78e1fd3257bbdf27722c46b500a39b6626fc8d27 |

## immich-base-images-rebuild

Evidence kind: `paired_timing`.

Original presentation source: [https://github.com/boringcache/base-images/actions/runs/31700820652](https://github.com/boringcache/base-images/actions/runs/31700820652).

### Observation 1

Original execution: [boringcache/base-images run 31700820652](https://github.com/boringcache/base-images/actions/runs/31700820652).

Export: **complete**, 7 listed files, archive directory `base-images/31700820652`.

| Field | Recorded value |
| --- | --- |
| project | immich-app/base-images |
| tool | Docker + ccache + mount cache |
| tool_page_slug | docker-build-cache |
| before_seconds | 6947 |
| after_seconds | 4463 |
| layer_seconds | 6787 |
| comparator | upstream-style GHCR registry |
| scenario | Node 24.14.1 to 24.18.0 rebuilds across dev, prod, AMD64, and ARM64 |
| trial_count | 3 |
| observation_count | 12 |
| paired_wins | 12 |
| passed_jobs | 98 |
| cache_errors | 0 |
| issue_candidates | 0 |
| final_image_push | false |
| seed_source_sha | a645c0ebfe59d53112d8773dca7936b5f90c684d |
| rebuild_source_sha | 9163399e7675da7e9087171a4ff2a49f815acc27 |
| product_refs.cli_version | v1.19.1 |
| product_refs.action_ref | boringcache/one@e24257b122813ad11d53b9ed024b474ca4946ad2 |

## discourse-arm64-cold-seed

Evidence kind: `paired_timing`.

Original presentation source: [https://github.com/boringcache/discourse_docker/actions/runs/31700383222](https://github.com/boringcache/discourse_docker/actions/runs/31700383222).

### Observation 1

Original execution: [boringcache/discourse_docker run 31700383222](https://github.com/boringcache/discourse_docker/actions/runs/31700383222).

Export: **complete**, 7 listed files, archive directory `discourse_docker/31700383222`.

| Field | Recorded value |
| --- | --- |
| project | discourse/discourse |
| tool | Docker + ccache + mount cache |
| tool_page_slug | docker-build-cache |
| before_seconds | 1406 |
| after_seconds | 1206 |
| layer_seconds | 1316 |
| comparator | actions/cache |
| scenario | Cold ARM64 image-factory seed across eight Bake targets |
| architecture | arm64 |
| source_sha | eedf0ac2344c37d66a2c9ab05dc8a83bf3efd9bb |
| product_refs.cli_version | v1.19.1 |
| product_refs.action_ref | boringcache/one@e24257b122813ad11d53b9ed024b474ca4946ad2 |

## bazel-remote-cache

Evidence kind: `paired_provider_timing`.

Original presentation source: [https://github.com/boringcache/benchmark-grpc/actions/runs/31382784321](https://github.com/boringcache/benchmark-grpc/actions/runs/31382784321).

### Observation 1

Original execution: [boringcache/benchmark-grpc run 31382784321](https://github.com/boringcache/benchmark-grpc/actions/runs/31382784321).

Export: **complete**, 13 listed files, archive directory `benchmark-grpc/31382784321`.

| Field | Recorded value |
| --- | --- |
| feature_rank | 4 |
| project | grpc/grpc |
| tool | Bazel |
| tool_page_slug | bazel-remote-cache |
| boringcache_seconds | 260 |
| comparator_seconds | 360 |
| comparator | BuildBuddy |
| same_source | true |
| product_refs.cli_version | v1.18.0 |
| product_refs.action_ref | boringcache/one@78e1fd3257bbdf27722c46b500a39b6626fc8d27 |

## tool-cache-storage

Evidence kind: `paired_storage_range`.

Original presentation source: [https://github.com/boringcache/benchmarks](https://github.com/boringcache/benchmarks).

### Observation 1

Original execution: [boringcache/benchmark-hugo-go run 27092625118](https://github.com/boringcache/benchmark-hugo-go/actions/runs/27092625118).

Export: **partial**, 6 listed files, archive directory `benchmark-hugo-go/27092625118`.

Missing evidence: {"resource" => "attempts/1/logs.zip", "reason" => "GitHub download unavailable for repos/boringcache/benchmark-hugo-go/actions/runs/27092625118/attempts/1/logs"}.

| Field | Recorded value |
| --- | --- |
| project | Hugo |
| tool_page_slug | go-build-cache |
| before_gib | 1.457 |
| after_gib | 0.279 |
| product_refs.cli_version | v1.13.40 |
| product_refs.action_ref | boringcache/one@4ba2a2c1afa5aa9a45b407674bf21456cfa884c6 |

### Observation 2

Original execution: [boringcache/benchmark-storybook run 29234064969](https://github.com/boringcache/benchmark-storybook/actions/runs/29234064969).

Export: **complete**, 9 listed files, archive directory `benchmark-storybook/29234064969`.

| Field | Recorded value |
| --- | --- |
| project | Storybook |
| tool_page_slug | nx-remote-cache |
| before_gib | 6.045 |
| after_gib | 0.841 |
| product_refs.cli_version | v1.13.92 |
| product_refs.action_ref | boringcache/one@d39427a8c278c17670e2fbb1b2ba9a699b61075f |

### Observation 3

Original execution: [boringcache/benchmark-opentelemetry-java run 29118580746](https://github.com/boringcache/benchmark-opentelemetry-java/actions/runs/29118580746).

Export: **complete**, 9 listed files, archive directory `benchmark-opentelemetry-java/29118580746`.

| Field | Recorded value |
| --- | --- |
| project | OpenTelemetry Java |
| tool_page_slug | gradle-build-cache |
| before_gib | 3.511 |
| after_gib | 0.758 |
| product_refs.cli_version | v1.13.92 |
| product_refs.action_ref | boringcache/one@d39427a8c278c17670e2fbb1b2ba9a699b61075f |

### Observation 4

Original execution: [boringcache/benchmark-spring-ai run 29232864168](https://github.com/boringcache/benchmark-spring-ai/actions/runs/29232864168).

Export: **complete**, 9 listed files, archive directory `benchmark-spring-ai/29232864168`.

| Field | Recorded value |
| --- | --- |
| project | Spring AI |
| tool_page_slug | maven-build-cache |
| before_gib | 4.574 |
| after_gib | 1.356 |
| product_refs.cli_version | v1.13.92 |
| product_refs.action_ref | boringcache/one@d39427a8c278c17670e2fbb1b2ba9a699b61075f |

### Observation 5

Original execution: [boringcache/benchmark-n8n run 29237867482](https://github.com/boringcache/benchmark-n8n/actions/runs/29237867482).

Export: **complete**, 9 listed files, archive directory `benchmark-n8n/29237867482`.

| Field | Recorded value |
| --- | --- |
| feature_rank | 5 |
| project | n8n-io/n8n |
| tool | Turbo |
| tool_page_slug | turborepo-remote-cache |
| before_gib | 12.773 |
| after_gib | 0.775 |
| product_refs.cli_version | v1.13.92 |
| product_refs.action_ref | boringcache/one@d39427a8c278c17670e2fbb1b2ba9a699b61075f |

### Observation 6

Original execution: [boringcache/benchmark-zed run 29213266895](https://github.com/boringcache/benchmark-zed/actions/runs/29213266895).

Export: **complete**, 13 listed files, archive directory `benchmark-zed/29213266895`.

| Field | Recorded value |
| --- | --- |
| project | Zed |
| tool_page_slug | sccache-remote-cache |
| before_gib | 11.46 |
| after_gib | 0.882 |
| product_refs.cli_version | v1.13.92 |
| product_refs.action_ref | boringcache/one@d39427a8c278c17670e2fbb1b2ba9a699b61075f |

## cargo-reuse

Evidence kind: `cache_reuse`.

Original presentation source: [https://github.com/boringcache/benchmark-deno/actions/runs/31538912668](https://github.com/boringcache/benchmark-deno/actions/runs/31538912668).

### Observation 1

Original execution: [boringcache/benchmark-deno run 31538912668](https://github.com/boringcache/benchmark-deno/actions/runs/31538912668).

Export: **complete**, 9 listed files, archive directory `benchmark-deno/31538912668`.

| Field | Recorded value |
| --- | --- |
| feature_rank | 6 |
| project | denoland/deno |
| tool | Cargo + sccache |
| tool_page_slug | rust-build-cache |
| hits | 1333 |
| misses | 58 |
| precision | 1 |
| context | Cargo target and sccache |
| product_refs.cli_version | v1.19.0 |
| product_refs.action_ref | boringcache/one@1d01e5dbf19ce259f921aa353d5e3e4ac5f942e4 |

## ccache-reuse

Evidence kind: `cache_reuse`.

Original presentation source: [https://github.com/boringcache/benchmark-obs-studio/actions/runs/31538912306](https://github.com/boringcache/benchmark-obs-studio/actions/runs/31538912306).

### Observation 1

Original execution: [boringcache/benchmark-obs-studio run 31538912306](https://github.com/boringcache/benchmark-obs-studio/actions/runs/31538912306).

Export: **complete**, 7 listed files, archive directory `benchmark-obs-studio/31538912306`.

| Field | Recorded value |
| --- | --- |
| project | obsproject/obs-studio |
| tool | ccache |
| tool_page_slug | ccache-remote-cache |
| hits | 447 |
| misses | 131 |
| precision | 0 |
| context | ccache remote compiler results |
| product_refs.cli_version | v1.19.0 |
| product_refs.action_ref | boringcache/one@1d01e5dbf19ce259f921aa353d5e3e4ac5f942e4 |

## docker-tool-cache-catalog

Evidence kind: `workload_catalog`.

Original presentation source: [https://github.com/boringcache/benchmark-docker/tree/02a87084f7891060a8d2815c9ab76e4b89063b18](https://github.com/boringcache/benchmark-docker/tree/02a87084f7891060a8d2815c9ab76e4b89063b18).

| Field | Recorded value |
| --- | --- |
| workload_count | 47 |
| coverage | ["Go build cache","sccache","Rust target cache mounts"] |
| source_revision | 02a87084f7891060a8d2815c9ab76e4b89063b18 |

This catalog describes the pinned historical workload coverage. It is not a timing comparison, and import of today's case definitions does not rerun that historical catalog.

## sccache-read-hit-latency

Evidence kind: `cache_read_latency`.

Original presentation source: [https://github.com/boringcache/host-rust-core/actions/runs/35680338088/job/106595748413](https://github.com/boringcache/host-rust-core/actions/runs/35680338088/job/106595748413).

### Observation 1

Original execution: [boringcache/host-rust-core run 35680338088](https://github.com/boringcache/host-rust-core/actions/runs/35680338088).

Export: **complete**, 9 listed files, archive directory `host-rust-core/35680338088`.

| Field | Recorded value |
| --- | --- |
| project | boringcache/host-rust-core |
| measurement | sccache_cache_read_hit |
| tool_version | 0.17.0 |
| platform | macOS ARM64 |
| hits | 1287 |
| cache_read_hit_duration_ns | 6465764927 |
| artifact_id | 10674641898 |
| artifact_file | sccache.json |
| product_refs.cli_version | v1.31.0 |
| product_refs.action_ref | boringcache/one@9ca311f9b247835b3cc87639321c79bac8018145 |

## proteus-docker

This additional website link points to an original workload run. This subsection preserves its execution and exported evidence; it adds no timing claim.

Original execution: [boringcache/proteus run 31390497300](https://github.com/boringcache/proteus/actions/runs/31390497300).

Source commit: `d536ce7f513d5af5d9b3f659337b0288d701af91`. Workflow: `.github/workflows/image.yml`. Original conclusion: `success`.

Export: **complete**, 7 listed files, archive directory `proteus/31390497300`. The bundle and inventory links above identify the preserved resources.

## proteus-cargo

This additional website link points to an original workload run. This subsection preserves its execution and exported evidence; it adds no timing claim.

Original execution: [boringcache/proteus run 31390497326](https://github.com/boringcache/proteus/actions/runs/31390497326).

Source commit: `d536ce7f513d5af5d9b3f659337b0288d701af91`. Workflow: `.github/workflows/check.yml`. Original conclusion: `success`.

Export: **complete**, 7 listed files, archive directory `proteus/31390497326`. The bundle and inventory links above identify the preserved resources.

## obs-xcode

This additional website link points to an original workload run. This subsection preserves its execution and exported evidence; it adds no timing claim.

Original execution: [boringcache/benchmark-obs-studio run 30664501753](https://github.com/boringcache/benchmark-obs-studio/actions/runs/30664501753).

Source commit: `27e5301f5f6847e323cf545522a4c99edf678b38`. Workflow: `.github/workflows/obs-xcode-continuation.yml`. Original conclusion: `success`.

Export: **complete**, 7 listed files, archive directory `benchmark-obs-studio/30664501753`. The bundle and inventory links above identify the preserved resources.
