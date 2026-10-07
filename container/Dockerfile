FROM ruby:4.0.7-slim-trixie

ARG BORINGCACHE_VERSION
ARG TARGETARCH

RUN apt-get update \
 && apt-get install --yes --no-install-recommends bash build-essential ca-certificates curl git unzip xz-utils \
 && rm -rf /var/lib/apt/lists/*

RUN curl --fail --silent --show-error --location https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh

RUN curl --fail --silent --show-error --location --remote-name-all \
      "https://github.com/boringcache/cli/releases/download/v${BORINGCACHE_VERSION}/boringcache-linux-${TARGETARCH}" \
      "https://github.com/boringcache/cli/releases/download/v${BORINGCACHE_VERSION}/SHA256SUMS" \
 && grep " boringcache-linux-${TARGETARCH}\$" SHA256SUMS | sha256sum --check \
 && install -m 0755 "boringcache-linux-${TARGETARCH}" /usr/local/bin/boringcache \
 && rm "boringcache-linux-${TARGETARCH}" SHA256SUMS

ENV PATH=/root/.local/share/mise/shims:$PATH \
    MISE_TRUSTED_CONFIG_PATHS=/work \
    MISE_YES=1

COPY Gemfile Gemfile.lock /tmp/bench/
RUN bundle install --gemfile /tmp/bench/Gemfile

WORKDIR /bench
