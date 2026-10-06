# October 6 baseline

These requests use harness commit `04dfe2e8fefb85fc93898059df208b2f4f3cf26e`
and published CLI canary `vcli-canary-8a5868ac875b`.

The [fresh dispatcher](https://github.com/boringcache/benchmarks/actions/runs/37429783479)
accepted all 31 targets. Its frozen plan and combined request receipt are retained
here. The 27 separately declared rolling seed requests retain their series plans
and per-run receipts under `results/`. Request acceptance does not establish
successful measurements. Deno and Zed keep their existing source-pair shapes in
the fresh selection; no changed-source rolling result is implied by a seed run.

[Hugo qualification](https://github.com/boringcache/benchmarks/actions/runs/37429493669)
passed both providers' cold and warm phases and reporting. The earlier failed
qualification retained a complete run report and exposed a comparator cache
publication problem, fixed before these baseline requests.

The [stable preflight](https://github.com/boringcache/benchmarks/actions/runs/37429038927)
rejected v1.33.0 because it lacks `cache-registry --reapi-port`. The
[source inspection](https://github.com/boringcache/benchmarks/actions/runs/37429130699)
retained recipe-review blocks for Zed (`script/bundle-linux`), Qdrant
(`Dockerfile`), and Zed Nix (`flake.lock`), preserving their reviewed pins.

Recurring central ownership is not yet enabled. All 48 historical schedule-only
patches were rechecked against current workflow blobs. Activation before a compatible stable release remains pending a user choice.
The user subsequently limited cleanup to October 5 migration experiments and
checks in the central GitHub Actions history. The deletion audit is retained in
`deleted-migration-runs.json`; scheduled runs, automated main-branch runs, other
repositories, and today's baseline are outside that cleanup. No caches were deleted.
