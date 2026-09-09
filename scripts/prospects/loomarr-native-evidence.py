"""Retain and check generated native commands without changing the build graph."""

import json
import os
import re
import shlex
import shutil
import subprocess
from pathlib import Path


def inspect_commands(entries, compiler_cache):
    compiled = {entry['output'] for entry in entries if entry['output'].endswith(('.o', '.obj', '.pch', '.gch'))}
    if not compiled:
        raise ValueError('No native compiler commands found')
    for entry in entries:
        wrappers = sum(Path(token).name == 'ccache' for token in shlex.split(entry['command']))
        expected = int(compiler_cache and entry['output'] in compiled)
        if wrappers != expected:
            raise ValueError(f"Expected {expected} ccache launchers for {entry['output']}, found {wrappers}")
    return len(compiled)


def main():
    source = Path.cwd()
    output = Path(os.environ['RUNNER_TEMP']) / 'prospect-evidence' / 'native'
    output.mkdir(parents=True, exist_ok=True)
    compiler_cache = os.environ['PROVIDER'] != 'baseline'
    expected_projects = {'app', 'react-native-reanimated', 'react-native-worklets', 'expo-modules-core'}
    abis = {'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'}
    groups = set()
    records = []
    failures = []
    for cache in sorted((source / 'web').rglob('CMakeCache.txt')):
        if not (cache.parent / 'build.ninja').exists():
            continue
        project = next((name for name in expected_projects - {'app'} if name in str(cache)), 'app')
        abi = next((name for name in abis if name in cache.parts), None)
        if abi is None:
            continue
        key = f'{project}-{abi}'
        destination = output / key
        destination.mkdir(exist_ok=True)
        for name in ('CMakeCache.txt', 'build.ninja', 'CMakeFiles/rules.ninja', '.ninja_log'):
            file = cache.parent / name
            if file.exists():
                shutil.copyfile(file, destination / file.name)
        match = re.search(r'^CMAKE_MAKE_PROGRAM:FILEPATH=(.+)$', cache.read_text(), re.MULTILINE)
        if not match:
            failures.append(f'{key}: missing CMake Ninja executable')
            continue
        result = subprocess.run([match[1], '-C', str(cache.parent), '-t', 'compdb'],
                                capture_output=True, text=True, check=True)
        (destination / 'commands.json').write_text(result.stdout)
        entries = json.loads(result.stdout)
        try:
            count = inspect_commands(entries, compiler_cache)
        except ValueError as error:
            failures.append(f'{key}: {error}')
            continue
        groups.add((project, abi))
        records.append({'project': project, 'abi': abi, 'compile_commands': count,
                        'build_directory': str(cache.parent.relative_to(source))})
    for project in expected_projects:
        for abi in abis:
            if (project, abi) not in groups:
                failures.append(f'Missing verified native commands: {project}/{abi}')
    report = {'groups': records, 'failures': failures, 'compiler_cache': compiler_cache}
    (output / 'coverage.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))
    raise SystemExit(bool(failures))


if __name__ == '__main__':
    main()
