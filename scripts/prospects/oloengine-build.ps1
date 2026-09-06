$ErrorActionPreference = 'Stop'
$workspace = $env:GITHUB_WORKSPACE.Replace('\', '/')
$vcpkg = $env:VCPKG_ROOT.Replace('\', '/')
$configure = @(
    '-S', '.', '-B', "$workspace/build", '-G', 'Ninja Multi-Config',
    '-DCMAKE_C_COMPILER=cl', '-DCMAKE_CXX_COMPILER=cl',
    '-DOLO_ENABLE_COMPILER_CACHE=ON', '-DOLO_ENABLE_LTO=OFF',
    "-DPython_EXECUTABLE=$env:OLO_PYTHON",
    '-DOLO_WITH_USD=OFF', '-DOLO_WITH_ALEMBIC=OFF', '-DOLO_WITH_MATERIALX=OFF',
    "-DCMAKE_TOOLCHAIN_FILE=$vcpkg/scripts/buildsystems/vcpkg.cmake",
    '-DVCPKG_TARGET_TRIPLET=x64-windows-static-md',
    '-DVCPKG_HOST_TRIPLET=x64-windows-static-md',
    "-DVCPKG_OVERLAY_PORTS=$workspace/cmake/overlay-ports",
    "-DVCPKG_OVERLAY_TRIPLETS=$workspace/cmake/triplets"
)
if (Test-Path 'OloEngine/vendor/ffmpeg-install/include') {
    $configure += "-DOLO_FFMPEG_PREFIX=$workspace/OloEngine/vendor/ffmpeg-install"
}
$timer = [Diagnostics.Stopwatch]::StartNew()
& cmake @configure
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$configureSeconds = $timer.Elapsed.TotalSeconds
& pwsh -NoProfile -File .claude/skills/run-oloengine/build-lock.ps1 -Jobs 4 `
    -Command 'cmake --build build --config Release --parallel 4'
$buildCode = $LASTEXITCODE
@{ configure_seconds = $configureSeconds; build_seconds = $timer.Elapsed.TotalSeconds - $configureSeconds;
   build_exit_code = $buildCode } | ConvertTo-Json |
    Set-Content "$env:RUNNER_TEMP/prospect-evidence/cmake-timings.json"
exit $buildCode
