set -euo pipefail

version="0.0.0-bench.g$(git -C upstream rev-parse --short=12 HEAD)"
manifest=codex-rs/Cargo.toml
lock=codex-rs/Cargo.lock
cd upstream
grep -qx 'version = "0.0.0"' "$manifest"
perl -0pi -e 's/^\[workspace\.package\]\nversion = "0\.0\.0"$/[workspace.package]\nversion = "'"$version"'"/m' "$manifest"
grep -qx "version = \"$version\"" "$manifest"
perl -0pi -e 's/^(\[\[package\]\]\nname = "[^"]+"\nversion = )"0\.0\.0"\n(?!source = )/$1"'"$version"'"\n/mg' "$lock"
test "$(grep -c "^version = \"$version\"$" "$lock")" -gt 0
test "$(grep -c '^version = "0.0.0"$' "$lock")" -eq 0
date=$(git log -1 --format=%cI)
GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git -c user.name=benchmark -c user.email=benchmark@localhost -c commit.gpgsign=false commit -q -m "Release $version" -- "$manifest" "$lock"
test -z "$(git status --porcelain)"
cd ..
printf '%s\n' "$version" > release-version
