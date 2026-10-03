# OBS ccache direct qualification

Both providers completed the declared cold parent and changed-source builds from
signed harness `d69d3332963eb6728f33982ac8292f9f28f82fb6`. BoringCache used CLI
1.33.0. Pinned recipe, native output, job completion, and post-step checks passed.

The one-sample screen measured cold build and reuse at 489.1 seconds with
BoringCache and 486.0 seconds with Actions Cache. Changed-source build and reuse
took 39.1 seconds and 37.8 seconds respectively. All observations are retained;
this sample does not establish a general provider advantage.

The declared scope includes cache restore/setup and the upstream
`Building obs-studio` log group. Dependency installation, CMake configuration,
queueing, and post-job cache save are excluded. Both arms used the pinned parent
and child on hosted Ubuntu 26.04 with matching recorded runner environments.

BoringCache reported 172,198,996 selected-tag bytes in both phases. Actions Cache
storage was unmeasured because the original reporting steps lacked a token.
Existing records retain that gap and cannot support a storage comparison.

The [generated report](report.json) contains every declared phase and completion.
[Durable evidence](evidence.md) was independently downloaded and verified. This qualifies execution of the
screening plan; publication review, ten-sample timing claims, and caller cutover
remain separate requirements.
