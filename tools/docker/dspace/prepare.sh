set -euo pipefail

source=upstream/Dockerfile
target=overlay/dspace-maven.Dockerfile
copy='COPY --chown=dspace . /app/'
build='RUN mvn --no-transfer-progress package ${MAVEN_FLAGS} && \'
extension='COPY --chown=dspace <<EOF /app/.mvn/extensions.xml'
always_run='RUN mvn --no-transfer-progress package ${MAVEN_FLAGS} -Dmaven.build.cache.alwaysRunPlugins=maven-assembly-plugin:single && \'

for line in "$copy" "$build"; do
  if [ "$(grep -cxF -- "$line" "$source")" != 1 ]; then
    echo "upstream/Dockerfile must contain this line exactly once: $line" >&2
    exit 1
  fi
done

mkdir -p overlay
COPY_LINE="$copy" BUILD_LINE="$build" EXTENSION_LINE="$extension" ALWAYS_RUN_LINE="$always_run" awk '
  $0 == ENVIRON["COPY_LINE"] {
    print
    print ENVIRON["EXTENSION_LINE"]
    print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    print "<extensions xmlns=\"http://maven.apache.org/EXTENSIONS/1.0.0\">"
    print "  <extension>"
    print "    <groupId>org.apache.maven.extensions</groupId>"
    print "    <artifactId>maven-build-cache-extension</artifactId>"
    print "    <version>1.3.0</version>"
    print "  </extension>"
    print "</extensions>"
    print "EOF"
    next
  }
  $0 == ENVIRON["BUILD_LINE"] {
    print ENVIRON["ALWAYS_RUN_LINE"]
    next
  }
  { print }
' "$source" > "$target"

for line in "$extension" "$always_run"; do
  if [ "$(grep -cxF -- "$line" "$target")" != 1 ]; then
    echo "$target is missing this line: $line" >&2
    exit 1
  fi
done
