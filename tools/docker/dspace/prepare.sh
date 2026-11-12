set -euo pipefail

source=upstream/Dockerfile
target=overlay/dspace-maven.Dockerfile
copy='COPY --chown=dspace . /app/'
build='RUN mvn --no-transfer-progress package ${MAVEN_FLAGS} && \'

for line in "$copy" "$build"; do
  if [ "$(grep -cxF -- "$line" "$source")" != 1 ]; then
    echo "upstream/Dockerfile must contain this line exactly once: $line" >&2
    exit 1
  fi
done

mkdir -p overlay
awk -v copy="$copy" -v build="$build" '
  $0 == copy {
    print
    print "COPY --chown=dspace <<EOF /app/.mvn/extensions.xml"
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
  $0 == build {
    print "RUN mvn --no-transfer-progress package ${MAVEN_FLAGS} -Dmaven.build.cache.alwaysRunPlugins=maven-assembly-plugin:single && \\"
    next
  }
  { print }
' "$source" > "$target"
