# Working on benchmarks

Read [docs/process.md](docs/process.md) before adding or changing a case. Use the
same contract and `bin/bench` interface for benchmarks and evaluations. Keep
commercial qualification notes outside this public repository.

## Case ownership

- Put definitions in `cases/<case-id>/case.json`. Keep IDs stable.
- Keep upstream source outside this repository. Pin complete commit SHAs; record
  patches and fidelity changes explicitly.
- Keep tool-specific behavior in adapters or case payloads. Shared harness
  behavior belongs in `scripts/`. Write maintained tooling and tests in Ruby.
- The CLI and `.boringcache.toml` own product cache configuration. Do not copy
  installers, product cache identity rules, or product evidence normalizers.
- Use `boringcache/benchmarks` for all plans. Separate case and series tags. Cold
  starts require fresh identity; rolling phases retain intended continuity.
  GitHub OIDC is the authentication method.
- Leave deferred forks unchanged. Do not schedule or import every historical
  prospect. Do not delete repositories without verified preservation.

## Measurement and reporting

- Declare the question, comparator, exact timed operation, verification, cache
  scope, and sample count before execution. Begin with bounded screening.
- Keep workload, source, outputs, architecture, runner class, and toolchain
  comparable across arms. Record provider-specific differences.
- Measure build and cache reuse, and provider storage. Queueing, apt mirror delays,
  and unrelated setup are context. Do not turn job duration into a build comparison.
  When upstream mixes setup into the entrypoint, record it explicitly and add a
  reviewed measurement boundary before making a narrower claim. Never subtract
  guessed setup durations.
- Keep cold, identical-source replay, and changed-source observations separate.
  Retain declared observations and failed runs. Do not select favorable pairs or
  remove slow results. Missing storage is unmeasured, not zero.
- Require output checks before timing supports a claim. A single-provider proof
  establishes correctness, not comparative performance.
- Export evidence before retention removes it. Preserve original URLs and attempts.
  Checksums establish exported-file integrity; inventory checks establish scoped
  completeness. Ordinary cache retention is not permanent evidence storage.
- Generate reports from structured records. Show measurements, units, sources,
  sample counts, missing data, and check results. Do not generate performance
  verdicts, suspected causes, recommendations, or review commentary. Keep human
  and AI analysis outside generated reports and the catalog. Preserve historical
  records and raw product evidence, including any original diagnostic fields.

## Verification

Run `bin/bench check`, Ruby tests, `scripts/check-registry-alignment.rb`,
`scripts/check-workflow-guardrails.rb`, `scripts/check-report-contract.rb`, and
`scripts/lint-workflows.rb`. Prepare the changed workload in a disposable directory and run
recipe and output verification. Record live-execution gaps honestly.

Use minimal permissions, immutable action pins, credential-free source checkouts,
and a separate reviewed publication step. Upstream code must not receive
credentials that can edit the harness or publish unrelated results.
