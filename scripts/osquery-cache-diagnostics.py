import collections
import json
import os
import pathlib
import shlex
import shutil
import subprocess

root = pathlib.Path(os.environ['RUNNER_TEMP'])
source = root / 'osquery-source'
build = root / 'osquery-build'
evidence = root / 'osquery-diagnostics'
evidence.mkdir(exist_ok=True)
env = dict(os.environ, CCACHE_CONFIGPATH=str(source / 'ccache.conf'), CCACHE_DIR=str(root / 'probe-ccache'), CCACHE_DEBUG='1', CCACHE_DEBUGDIR=str(evidence / 'debug'), CCACHE_STATSLOG=str(evidence / 'probe-stats.log'))


def run(args, **kwargs):
    return subprocess.run(args, check=True, text=True, **kwargs)


def configure(label):
    run(['cmake', '-S', str(source), '-B', str(build), '-G', 'Unix Makefiles', '-DOSQUERY_TOOLCHAIN_SYSROOT:PATH=/usr/local/osquery-toolchain', '-DCMAKE_BUILD_TYPE:STRING=Release', '-DOSQUERY_BUILD_TESTS=ON', '-DOSQUERY_BUILD_ROOT_TESTS=ON', '-DOSQUERY_NO_DEBUG_SYMBOLS=OFF'], env=env)
    commands = json.loads((build / 'compile_commands.json').read_text())
    (evidence / (label + '-commands.json')).write_text(json.dumps(commands, indent=2))
    return commands


def probe(commands, label):
    choices = [entry for entry in commands if 'thirdparty_aws-cpp-sdk-core.dir/cmake_pch' in entry.get('output', entry['command'])]
    choices += [entry for entry in commands if entry['file'].endswith('/aws-cpp-sdk-ec2/source/model/CreateVolumeRequest.cpp')]
    print('Selected probe commands:', label, json.dumps(choices), flush=True)
    for entry in choices:
        args = shlex.split(entry['command'])
        output = pathlib.Path(args[args.index('-o') + 1])
        if not output.is_absolute():
            output = pathlib.Path(entry['directory']) / output
        output.parent.mkdir(parents=True, exist_ok=True)
        run(['ccache', *args], cwd=entry['directory'], env=env)
    result = run(['ccache', '--print-log-stats', '--format=json'], env=env, capture_output=True)
    (evidence / (label + '-stats.json')).write_text(result.stdout)
    print(label, result.stdout, flush=True)


first = configure('step-0')
probe(first, 'initial')
probe(first, 'same-inputs')
run(['git', '-C', str(source), 'checkout', '775e6896c3b9bdd04152e5140fc2f69190267568'])
second = configure('step-1')
probe(second, 'changed-commit')
left = {entry['file']: entry for entry in first}
right = {entry['file']: entry for entry in second}
changes = [{'file': path, 'before': left[path]['command'], 'after': right[path]['command']} for path in left.keys() & right.keys() if left[path]['command'] != right[path]['command']]
summary = {'step_0_commands': len(first), 'step_1_commands': len(second), 'changed_commands': len(changes), 'unchanged_commands': len(left.keys() & right.keys()) - len(changes), 'changed_by_directory': dict(collections.Counter('/'.join(pathlib.Path(change['file']).relative_to(source).parts[:2]) if change['file'].startswith(str(source)) else 'generated' for change in changes))}
(evidence / 'command-changes.json').write_text(json.dumps(changes, indent=2))
(evidence / 'summary.json').write_text(json.dumps(summary, indent=2))
print('COMMAND COMPARISON', json.dumps(summary), flush=True)
