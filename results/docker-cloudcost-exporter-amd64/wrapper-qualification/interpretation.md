# Docker wrapper qualification

The pinned AMD64 cloudcost-exporter cold and warm builds passed recipe fidelity,
declared output behavior, and preserved completion checks. This is a BoringCache
product proof, with one sample and no comparator. It does not establish a timing
or storage advantage, or qualify the other Docker workloads and architectures.

The upstream recipe declares no image load or publication. Successful execution
verifies that behavior and the build; it does not verify a runnable loaded image.
Both jobs use CLI 1.33.0 and the declared case/series cache identity in the shared
workspace. [evidence.md](evidence.md) links the original execution and independently
verified preserved evidence.

[cache-telemetry.json](cache-telemetry.json) retains the cache-side observations.
The warm job served 16 Docker cache objects with no missed objects or cache errors.
Across the two builds, BuildKit reported eight cached steps and 29 executed steps.
The Go compile step executed again in the warm job. Upstream embeds build-time
metadata, and the preserved logs retain that command. The pinned source alone
does not make every effective build input identical.

Object counts are not compiler hit rates. The generated records leave storage
unmeasured. Cache-server durations can overlap; they must not be added to create
a wall-clock comparison. Keep this qualification separate from comparative
benchmark claims. The earlier `consolidated-docker-proof` series remains
unqualified because its post-step logs reported publication failures.
