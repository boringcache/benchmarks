# Historical ECR measurements

Selected on 2026-07-21. This cache lane is retired.

The table is an archive of existing artifacts; this retirement did not trigger
new ECR runs. Values are arithmetic means over the latest three healthy rolling
samples selected on 2026-07-21 by [the historical index publisher](https://github.com/boringcache/benchmarks/blob/3e705f46e31638de5e323480445b29a92cce3df4/scripts/publish-index.rb):

- **Scenario** is the benchmark's measured rolling scenario duration.
- **Tool elapsed** is scenario time plus cache export and any recorded
  post-cleanup time. It is the provider-comparison headline.
- **Import** and **export** are BuildKit cache operations reported by the
  benchmark artifact.
- **Stored** is ECR's reported compressed cache-manifest size, not an AWS bill.

| Scenario | n | Scenario | Tool elapsed | Import | Export | Stored | Raw runs |
|---|---:|---:|---:|---:|---:|---:|---|
| Hugo | 3 | 73.7s | 77.5s | 0.7s | 3.8s | 0.34 GiB | [29716349889](https://github.com/boringcache/benchmark-hugo/actions/runs/29716349889), `29240125044`, `29223295753` |
| Immich | 3 | 219.0s | 322.5s | 0.5s | 103.5s | 2.88 GiB | [29844467738](https://github.com/boringcache/benchmark-immich/actions/runs/29844467738), `29840235010`, `29835289611` |
| Mastodon | 3 | 133.7s | 170.6s | 0.9s | 36.9s | 1.03 GiB | [29844771395](https://github.com/boringcache/benchmark-mastodon/actions/runs/29844771395), `29835532384`, `29817877222` |
| Mastodon Streaming | 3 | 18.3s | 18.8s | 0.6s | 0.5s | 0.10 GiB | [29844772254](https://github.com/boringcache/benchmark-mastodon/actions/runs/29844772254), `29835533448`, `29817880029` |
| Discourse Docker | 3 | 206.0s | 250.2s | 0.9s | 44.2s | 1.03 GiB | [29857843705](https://github.com/boringcache/benchmark-discourse/actions/runs/29857843705), `29853103741`, `29846604467` |
| Discourse Base Deps | 3 | 15.7s | 17.0s | 0.7s | 1.4s | 0.70 GiB | [29857851547](https://github.com/boringcache/benchmark-discourse/actions/runs/29857851547), `29853101963`, `29846602123` |
| Discourse Web-Only | 3 | 14.0s | 15.2s | 0.6s | 1.2s | 1.40 GiB | [29857851547](https://github.com/boringcache/benchmark-discourse/actions/runs/29857851547), `29853101963`, `29846602123` |
| Discourse Base Release | 3 | 14.7s | 16.2s | 0.7s | 1.5s | 1.50 GiB | [29857851547](https://github.com/boringcache/benchmark-discourse/actions/runs/29857851547), `29853101963`, `29846602123` |
| Discourse Test Release | 3 | 17.7s | 19.4s | 0.8s | 1.8s | 1.95 GiB | [29857851547](https://github.com/boringcache/benchmark-discourse/actions/runs/29857851547), `29853101963`, `29846602123` |
| PostHog | 3 | 1187.0s | 1612.5s | 0.7s | 425.5s | 7.14 GiB | [29859494860](https://github.com/boringcache/benchmark-posthog/actions/runs/29859494860), `29857487121`, `29853289104` |
| n8n | 3 | 282.3s | 383.5s | 0.8s | 101.2s | 0.77 GiB | [29859464651](https://github.com/boringcache/benchmark-n8n/actions/runs/29859464651), `29857454069`, `29844629886` |
| n8n Runners | 3 | 62.3s | 83.2s | 0.8s | 20.8s | 0.28 GiB | [29859464651](https://github.com/boringcache/benchmark-n8n/actions/runs/29859464651), `29857454069`, `29844629886` |
| n8n Runners Distroless | 3 | 108.0s | 147.1s | 0.8s | 39.1s | 0.47 GiB | [29859464651](https://github.com/boringcache/benchmark-n8n/actions/runs/29859464651), `29857454069`, `29844629886` |

Stored manifest sizes are not billed storage. Request and transfer charges are separate.
