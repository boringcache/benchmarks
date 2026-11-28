ARG SCCACHE_VERSION=0.17.0
ARG TARGETARCH
RUN set -eu; \
    case "${TARGETARCH}" in \
      amd64) target=x86_64-unknown-linux-musl; checksum=67c4a96dd237c1f518f6b36083f270f9976d516f1e57fce891755ea782e50006 ;; \
      arm64) target=aarch64-unknown-linux-musl; checksum=821a86343191aa1cbab74bd42f9e93c9a63bf85e4742945f40d3ae84193c1c77 ;; \
      *) echo "Unsupported sccache architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    package="sccache-v${SCCACHE_VERSION}-${target}"; \
    curl --fail --location --show-error --silent --retry 3 \
      "https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/${package}.tar.gz" \
      --output "/tmp/${package}.tar.gz"; \
    printf '%s  %s\n' "$checksum" "/tmp/${package}.tar.gz" | sha256sum --check --strict; \
    tar --extract --gzip --file "/tmp/${package}.tar.gz" --directory /tmp; \
    install --mode=0755 "/tmp/${package}/sccache" /usr/local/bin/sccache; \
    rm --recursive --force "/tmp/${package}.tar.gz" "/tmp/${package}"; \
    sccache --version
