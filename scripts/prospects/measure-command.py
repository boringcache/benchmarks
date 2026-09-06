"""Time an unchanged workload command and retain its native output."""

import json
import os
import subprocess
import sys
import time
from pathlib import Path


def main():
    label, separator, *command = sys.argv[1:]
    if separator != "--" or not command:
        raise SystemExit("usage: measure-command.py LABEL -- COMMAND [ARG ...]")
    evidence = Path(os.environ["RUNNER_TEMP"]) / "prospect-evidence"
    evidence.mkdir(parents=True, exist_ok=True)
    os.environ["BORINGCACHE_OBSERVABILITY_JSONL_PATH"] = str(evidence / "product.jsonl")
    record = {
        "label": label,
        "command": command,
        "source_sha": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
        **{key.lower(): os.environ.get(key) for key in (
            "PROSPECT", "PROVIDER", "PHASE", "UPSTREAM_SHA", "GITHUB_RUN_ID",
            "GITHUB_RUN_ATTEMPT", "GITHUB_JOB", "GITHUB_SHA", "RUNNER_OS", "RUNNER_ARCH",
        )},
        "started_at": time.time(),
    }
    started = time.monotonic()
    with (evidence / (label + ".log")).open("w", encoding="utf-8") as log:
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                   text=True, encoding="utf-8", errors="replace", bufsize=1)
        for line in process.stdout:
            print(line, end="", flush=True)
            log.write(line)
        code = process.wait()
    record.update(seconds=round(time.monotonic() - started, 3),
                  completed_at=time.time(), exit_code=code)
    (evidence / (label + ".json")).write_text(json.dumps(record, indent=2) + "\n")
    with (evidence / "source-changes.diff").open("w") as output:
        subprocess.run(["git", "diff", "--no-ext-diff"], stdout=output, check=True)
    print(json.dumps(record), flush=True)
    raise SystemExit(code)


if __name__ == "__main__":
    main()
