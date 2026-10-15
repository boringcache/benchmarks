import collections
import json
import os
import pathlib
import shlex
import shutil
import subprocess

root = pathlib.Path(os.environ['RUNNER_TEMP'])
source = pathlib.Path('/home/runner/w/ccache/osquery/upstream')
build = source.parent / 'build'
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


def probe(commands, label, probe_env=None, wrapper='ccache'):
    probe_env = probe_env or env
    choices = [entry for entry in commands if 'thirdparty_aws-cpp-sdk-core.dir/cmake_pch' in entry.get('output', entry['command'])]
    choices += [entry for entry in commands if entry['file'].endswith('/aws-cpp-sdk-ec2/source/model/CreateVolumeRequest.cpp')]
    print('Selected probe commands:', label, json.dumps(choices), flush=True)
    for entry in choices:
        args = shlex.split(entry['command'])
        output = pathlib.Path(args[args.index('-o') + 1])
        if not output.is_absolute():
            output = pathlib.Path(entry['directory']) / output
        output.parent.mkdir(parents=True, exist_ok=True)
        target_dir = output.relative_to(pathlib.Path(entry['directory'])).parts[:2]
        makefile = pathlib.Path(entry['directory']).joinpath(*target_dir) / 'build.make'
        recipes = [line.strip() for line in makefile.read_text().splitlines() if line.startswith('\t') and ' -c ' in line and str(entry['file']) in line and ' -o ' in line]
        exact = next(shlex.split(line) for line in recipes if args[0] in shlex.split(line))
        exact = exact[exact.index(args[0]):]
        (evidence / (label + '-' + output.name + '-invocation.json')).write_text(json.dumps(exact, indent=2))
        result = subprocess.run([wrapper, *exact], cwd=entry['directory'], env=probe_env, text=True)
        print('PROBE EXIT', label, output.name, result.returncode, flush=True)
    result = run(['ccache', '--print-log-stats', '--format=json'], env=probe_env, capture_output=True)
    (evidence / (label + '-stats.json')).write_text(result.stdout)
    print(label, result.stdout, flush=True)


saved_env = dict(env, CCACHE_DIR=str(source.parent / '.ccache'), CCACHE_READONLY='1', CCACHE_STATSLOG=str(evidence / 'saved-cache-stats.log'))
first = configure('step-0')
probe(first, 'saved-step-0', saved_env)
probe(first, 'initial')
probe(first, 'same-inputs')
run(['git', '-C', str(source), 'checkout', '775e6896c3b9bdd04152e5140fc2f69190267568'])
second = configure('step-1')
probe(second, 'changed-commit')
probe(second, 'saved-step-1', saved_env)
shutil.rmtree(build)
for path in source.rglob('*'):
    if path.is_file() and '.git' not in path.parts:
        os.utime(path, None)
third = configure('fresh-checkout')
probe(third, 'fresh-checkout')
probe(third, 'saved-fresh-checkout', saved_env)
left = {entry['file']: entry for entry in first}
right = {entry['file']: entry for entry in second}
changes = [{'file': path, 'before': left[path]['command'], 'after': right[path]['command']} for path in left.keys() & right.keys() if left[path]['command'] != right[path]['command']]
summary = {'step_0_commands': len(first), 'step_1_commands': len(second), 'changed_commands': len(changes), 'unchanged_commands': len(left.keys() & right.keys()) - len(changes), 'changed_by_directory': dict(collections.Counter('/'.join(pathlib.Path(change['file']).relative_to(source).parts[:2]) if change['file'].startswith(str(source)) else 'generated' for change in changes))}
(evidence / 'command-changes.json').write_text(json.dumps(changes, indent=2))
(evidence / 'summary.json').write_text(json.dumps(summary, indent=2))
print('COMMAND COMPARISON', json.dumps(summary), flush=True)

mini = root / 'version-probe'
mini.mkdir(exist_ok=True)
(mini / 'same.cpp').write_text('int unchanged() { return 42; }\n')
for mode in ('depend', 'fallback'):
    mini_env = dict(env, CCACHE_DIR=str(mini / mode), CCACHE_STATSLOG=str(evidence / (mode + '-version.log')))
    if mode == 'fallback':
        mini_env['CCACHE_NODEPEND'] = '1'
    for version in ('first', 'second'):
        run(['ccache', '/usr/local/osquery-toolchain/usr/bin/clang++', '--sysroot=/usr/local/osquery-toolchain', '-DOSQUERY_VERSION=' + version, '-MD', '-MF', str(mini / 'same.d'), '-c', str(mini / 'same.cpp'), '-o', str(mini / 'same.o')], env=mini_env)
    stats = run(['ccache', '--print-log-stats', '--format=json'], env=mini_env, capture_output=True)
    (evidence / (mode + '-version.json')).write_text(stats.stdout)

sccache_env = {key: value for key, value in os.environ.items() if not key.startswith('SCCACHE_')}
sccache_env.update(SCCACHE_DIR=str(mini / 'sccache'), SCCACHE_SERVER_UDS=str(mini / 'sccache.sock'))
try:
    for version in ('first', 'first', 'second'):
        run(['sccache', '/usr/local/osquery-toolchain/usr/bin/clang++', '--sysroot=/usr/local/osquery-toolchain', '-DOSQUERY_VERSION=' + version, '-MD', '-MF', str(mini / 'same.d'), '-c', str(mini / 'same.cpp'), '-o', str(mini / 'same.o')], env=sccache_env)
    stats = run(['sccache', '--show-stats', '--stats-format', 'json'], env=sccache_env, capture_output=True)
    (evidence / 'sccache-version.json').write_text(stats.stdout)
finally:
    run(['sccache', '--stop-server'], env=sccache_env)
