# Latest Benchmark Report

Generated: 2026-10-05 14:01 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 5/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | Actions Cache | BoringCache | Time difference (BoringCache − Actions Cache) | Storage difference (BoringCache − Actions Cache) | Sample status |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold build | 269.0s | 207.0s | -62.0s | unmeasured | recorded |
| Hugo Go | Cold build | 71.0s | 77.0s | +6.0s | +649959161 bytes | recorded |
| Immich | Cold build | 242.0s | 144.0s | -98.0s | unmeasured | recorded |
| Mastodon | Cold build | 629.0s | 405.0s | -224.0s | unmeasured | recorded |
| Mastodon Streaming | Warm build | 16.0s | 10.0s | -6.0s | unmeasured | recorded |
| Discourse Image Factory (amd64) | Cold build | 2589.0s | 2506.0s | -83.0s | unmeasured | recorded |
| Discourse Image Factory (arm64) | Cold build | 2338.0s | 2821.0s | +483.0s | unmeasured | recorded |
| PostHog | Cold build | 2053.0s | 848.0s | -1205.0s | unmeasured | recorded |
| Storybook | Cold build | 226.0s | 371.0s | +145.0s | unmeasured | recorded |
| OpenTelemetry Java | Cold build | 860.0s | 880.0s | +20.0s | unmeasured | recorded |
| Spring AI | Cold build | 521.0s | 465.0s | -56.0s | unmeasured | recorded |
| gRPC | Cold build | 1644.0s | 2059.0s | +415.0s | unmeasured | recorded |
| Duckgres | Cold build | 405.0s | 188.0s | -217.0s | unmeasured | recorded |
| Chroma | Warm build | 3622.0s | 148.0s | -3474.0s | unmeasured | recorded |
| Linkerd2 Web | Cold build | 307.0s | 193.0s | -114.0s | unmeasured | recorded |
| Qdrant | Cold build | 662.0s | 605.0s | -57.0s | unmeasured | recorded |
| n8n | Cold build | 143.0s | 139.0s | -4.0s | unmeasured | recorded |
| n8n Docker | Warm build | 114.0s | 66.0s | -48.0s | unmeasured | recorded |
| n8n Runners | Warm build | 1018.0s | 35.0s | -983.0s | unmeasured | recorded |
| n8n Runners Distroless | Cold build | 180.0s | 66.0s | -114.0s | unmeasured | recorded |

## Rolling

| Benchmark | Metric | Actions Cache | BoringCache | Time difference (BoringCache − Actions Cache) | Storage difference (BoringCache − Actions Cache) | Sample status |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo Go | Changed-source build | 23.0s | 30.0s | +7.0s | -494173650 bytes | recorded |
| OpenTelemetry Java | Changed-source build | 60.0s | 71.0s | +11.0s | -1003826009 bytes | recorded |
| Chroma | Changed-source build | 1221.0s | 654.0s | -567.0s | unmeasured | recorded |
| Linkerd2 Web | Changed-source build | 16.0s | 9.0s | -7.0s | unmeasured | recorded |
| n8n | Changed-source build | 251.0s | 211.0s | -40.0s | -2108038865 bytes | recorded |
