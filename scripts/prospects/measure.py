"""Measure a pinned prospect workload and retain the tool's unmodified output."""

import json
import os
import subprocess
import sys
import time
from pathlib import Path

import tomllib


def main():
    case, provider, phase = sys.argv[1:]
    sources = json.loads(Path(__file__).with_name("sources.json").read_text())
    source = sources[case]
    checkout = Path(os.environ["GITHUB_WORKSPACE"]) / "source"
    cwd = checkout / source["working_directory"]
    evidence = Path(os.environ["RUNNER_TEMP"]) / "prospect-evidence"
    evidence.mkdir(parents=True, exist_ok=True)
    os.environ["BORINGCACHE_OBSERVABILITY_JSONL_PATH"] = str(evidence / "product.jsonl")
    sha = subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=checkout, text=True
    ).strip()
    if sha != source["source_sha"]:
        raise SystemExit("The checkout differs from the pinned prospect source")

    plan = tomllib.loads((cwd / ".boringcache.toml").read_text())
    mode = source["mode"]
    command = (
        ["make", "android"] if case == "loomarr" else plan["adapters"][mode]["command"]
    )
    if case == "loomarr":
        os.environ["LOOMARR_ANDROID_GRADLE_CACHE"] = (
            "gradle"
            if provider == "github"
            else "boringcache"
            if phase == "cold"
            else "boringcache-restore"
        )
        if provider == "boringcache":
            command = [
                "boringcache",
                "ci",
                "run",
                "--oidc-provider",
                "github-actions",
                "--",
                *command,
            ]
    elif provider == "boringcache":
        command = [
            "boringcache",
            "ci",
            "run",
            "--oidc-provider",
            "github-actions",
            "--",
            "boringcache",
            mode,
            "--write" if phase == "cold" else "--read-only",
            "--fail-on-cache-error",
        ]
    elif mode == "docker":
        scope = f"prospect-{case}-{os.environ['GITHUB_RUN_ID']}-{os.environ['GITHUB_RUN_ATTEMPT']}"
        command += ["--progress=plain", f"--cache-from=type=gha,scope={scope}"]
        if phase == "cold":
            command += [f"--cache-to=type=gha,scope={scope},mode=max"]

    record = {
        **source,
        "case": case,
        "provider": provider,
        "phase": phase,
        "command": command,
        "workflow_sha": os.environ["GITHUB_SHA"],
        "run_id": os.environ["GITHUB_RUN_ID"],
        "run_attempt": os.environ["GITHUB_RUN_ATTEMPT"],
        "job": os.environ["GITHUB_JOB"],
        "runner_os": os.environ["RUNNER_OS"],
        "runner_arch": os.environ["RUNNER_ARCH"],
        "started_at": time.time(),
    }
    started = time.monotonic()
    with (evidence / "workload.log").open("w") as log:
        process = subprocess.Popen(
            command,
            cwd=cwd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )
        for line in process.stdout:
            print(line, end="", flush=True)
            log.write(line)
        exit_code = process.wait()
    record.update(
        measured_command_seconds=round(time.monotonic() - started, 3),
        completed_at=time.time(),
        exit_code=exit_code,
    )
    (evidence / "benchmark.json").write_text(json.dumps(record, indent=2) + "\n")
    print(json.dumps(record), flush=True)
    raise SystemExit(exit_code)


if __name__ == "__main__":
    main()
