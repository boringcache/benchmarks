# Unkey Go commit replay

The source window is ten consecutive first-parent commits ending at
`d0b1e2997c93944393afefb341c37cae1cb107d5`, frozen on November 4, 2026.
`tools/go/unkey/commits.json` records their order and changed files. Five change
Go source. Dispatch positions 0 through 9 in order with one unique series ID,
after collecting each preceding run. The replay has no schedule or main-branch
result publication.

Every lane runs the upstream `mise run build` followed by `mise run test`.
The first includes SQL lint tests, SQL lint, golangci-lint, `go build ./...`,
and the CLI build. The second runs Rask with the upstream container lifecycle.
The upstream tree is unmodified. Output checks require the CLI help command to
succeed and tracked source files to remain unchanged.

All lanes run on `depot-ubuntu-24.04-8` GitHub Actions runners. This is a
controlled replay on Depot's Actions service, not a measurement of Unkey's
Depot CI account. The local machine is not used for performance measurements.

| Lane | Go compilation | Other retained state |
| --- | --- | --- |
| `archive-cache` | Native Go disk cache archived with actions/cache | Go modules, Rask verdicts, golangci-lint cache |
| `depot-cache-replay` | `GOCACHEPROG="depot gocache --verbose"` | Same state, archived with actions/cache |
| `boringcache-go` | Released BoringCache Go adapter | Same state through its dependency profile |

Provider setup follows [Depot Go caching](https://depot.dev/docs/cache/integrations/gocache)
and [GitHub cache usage](https://docs.github.com/en/actions/reference/workflows-and-actions/dependency-caching).
Depot's Actions runners route actions/cache through
[Depot Cache](https://depot.dev/docs/cache/integrations/github-actions).
The archive lane explicitly clears automatic `GOCACHEPROG` configuration.

These differences from Unkey's configuration limit interpretation:

- Unkey uses an S3-compatible Rask remote cache. This replay retains the same
  local verdict objects through each lane's archive backend. It does not
  reproduce the latency, contents or credentials of Unkey's Rask bucket.
- Unkey's Go archive key is based on platform, event, toolchain and `go.sum`.
  This replay writes a new archive each step, retaining newer compiled outputs.
  It measures a rolling archive comparison rather than reproducing that fixed
  key's history.
- Only the three locked tools needed by the Go job are installed. Unkey's
  shared setup installs its full toolchain and also caches pnpm. Preparation is
  outside the harness measurement and must not be presented as a total CI-job
  saving.
- Depot Go Cache has no isolated series namespace in this setup. Its initial
  seed may find existing shared objects. Do not describe that lane's seed as a
  proven empty cache.
- The ten-commit series has one observation per commit per lane. It screens
  behavior; it does not establish a repeatable performance advantage.

The shared phase action retains original records and BoringCache evidence.
Separate artifacts retain machine details and GNU time output for build and
test commands. Process CPU time excludes work done by Docker daemon processes;
low measured CPU use alone does not identify network or container waiting.
Rask's summary provides suite cache outcomes. Cache setup, restore, build and
save retain the harness timing boundary; preparation and job wall time are
separate context.
