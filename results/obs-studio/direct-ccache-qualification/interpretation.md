# OBS ccache preparation failure

Both declared providers stopped in harness preparation. BoringCache run
`37063464018` and Actions Cache run `37063467317` used signed harness
`50f069f123cef134e307db653c853d39eee08404`, Ubuntu 26.04, and Ruby 3.4.4.
Ruby setup requested an Ubuntu 26.04 binary that returned HTTP 404. No upstream
build, cache operation, output check, or timing observation completed.

The exported jobs and logs verify this failure in both arms. Completion records
are failed, and all four declared cold/changed-source observations remain missing.
The series cannot support correctness, performance, or storage claims. It remains
preserved rather than being replaced with a successful rerun.

The pinned upstream OBS workflow also uses Ubuntu 26.04. The replacement retains
that image and source recipe, moves the shared harness to a supported Ruby patch,
and uses a new predeclared series. Ruby preparation remains outside the measured
build and reuse operation. See the [report](report.md).
