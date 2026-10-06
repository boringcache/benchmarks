# Latest Benchmark Report

Generated: 2026-10-06 10:16 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 9/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | Actions Cache | BoringCache | Time difference (BoringCache − Actions Cache) | Storage difference (BoringCache − Actions Cache) | Sample status |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold build | 269.0s | 207.0s | -62.0s | unmeasured | recorded |
| Hugo Go | Cold build | 71.0s | 77.0s | +6.0s | +649959161 bytes | recorded |
| Immich | Cold build | 242.0s | 144.0s | -98.0s | unmeasured | recorded |
| Mastodon | Cold build | 713.0s | 506.0s | -207.0s | unmeasured | recorded |
| Mastodon Streaming | Cold build | 27.0s | 25.0s | -2.0s | unmeasured | recorded |
| Discourse Image Factory (amd64) | Cold build | 2589.0s | 2506.0s | -83.0s | unmeasured | recorded |
| Discourse Image Factory (arm64) | Cold build | 2338.0s | 2821.0s | +483.0s | unmeasured | recorded |
| PostHog | Cold build | 2053.0s | 848.0s | -1205.0s | unmeasured | recorded |
| Storybook | Cold build | 224.0s | 279.0s | +55.0s | unmeasured | recorded |
| OpenTelemetry Java | Cold build | 989.0s | 911.0s | -78.0s | unmeasured | recorded |
| Spring AI | Cold build | 521.0s | 465.0s | -56.0s | unmeasured | recorded |
| gRPC | Cold build | 1644.0s | 2059.0s | +415.0s | unmeasured | recorded |
| Duckgres | Cold build | 405.0s | 188.0s | -217.0s | unmeasured | recorded |
| Chroma | Warm build | 3622.0s | 148.0s | -3474.0s | unmeasured | recorded |
| Linkerd2 Web | Cold build | 307.0s | 193.0s | -114.0s | unmeasured | recorded |
| Qdrant | Cold build | 662.0s | 605.0s | -57.0s | unmeasured | recorded |
| n8n | Cold build | 143.0s | 139.0s | -4.0s | unmeasured | recorded |
| n8n Docker | Warm build | 153.0s | 88.0s | -65.0s | unmeasured | recorded |
| n8n Runners | Warm build | 59.0s | 38.0s | -21.0s | unmeasured | recorded |
| n8n Runners Distroless | Warm build | 144.0s | 66.0s | -78.0s | unmeasured | recorded |

## Rolling

| Benchmark | Metric | Actions Cache | BoringCache | Time difference (BoringCache − Actions Cache) | Storage difference (BoringCache − Actions Cache) | Sample status |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Changed-source build | 180.0s | 167.0s | -13.0s | -831244853 bytes | recorded |
| Hugo Go | Changed-source build | 23.0s | 30.0s | +7.0s | -494173650 bytes | recorded |
| OpenTelemetry Java | Changed-source build | 60.0s | 71.0s | +11.0s | -1003826009 bytes | recorded |
| Spring AI | Changed-source build | 49.0s | 46.0s | -3.0s | -1324873908 bytes | recorded |
| Chroma | Changed-source build | 1221.0s | 654.0s | -567.0s | unmeasured | recorded |
| Linkerd2 Web | Changed-source build | 16.0s | 9.0s | -7.0s | unmeasured | recorded |
| n8n Docker | Changed-source build | 254.0s | 182.0s | -72.0s | unmeasured | investigation only |
| n8n Runners | Changed-source build | 54.0s | 40.0s | -14.0s | unmeasured | recorded |
| n8n Runners Distroless | Changed-source build | 112.0s | 108.0s | -4.0s | unmeasured | recorded |
