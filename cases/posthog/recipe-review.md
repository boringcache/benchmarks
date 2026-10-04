# PostHog shared execution review

The native fresh comparison uses the pinned upstream Dockerfile for `layers`
and the declared tool-cache projection for `combined`. Both providers build,
export, and load the selected image. The shared output verifier inspects it after
the build timer stops. This check establishes image materialization, not runtime
application correctness.

The [first image-output screening run](https://github.com/boringcache/benchmarks/actions/runs/37104600856)
completed both cold jobs, then failed both warm jobs because the legacy scope
assertion ran before the series scope was resolved. Its cold build timings also
include a superseded image inspection. Retain those original records as
diagnostic evidence; they do not satisfy the declared timing contract.

For a declared series, resolve the existing deterministic scope before the
legacy warm branch. Cold and warm share case, series, sample, run, and attempt
identity. Legacy callers without a series still pass the cold scope explicitly,
and a warm call without that scope fails. Cache-miss enforcement is unchanged.

The correction removes both old inspection steps. One shared verifier runs after
timing capture. Regression tests execute the action's scope shell with inputs
from the generated wrapper for both providers and variants, check the legacy
handoff, and require every Docker output inspection to follow timing capture.
Corrected execution requires a new predeclared series and a new harness ref.
