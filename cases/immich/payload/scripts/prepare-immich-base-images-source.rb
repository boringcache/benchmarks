#!/usr/bin/env ruby
# frozen_string_literal: true

profile, source = ARGV
raise "Profile must be baseline or ccache" unless %w[baseline ccache].include?(profile)
path = File.join(source, "server", "Dockerfile")
text = File.read(path)
if profile == "ccache"
  replacements = {"  build-essential \\\n  cmake \\\n" => "  build-essential \\\n  ccache \\\n  cmake \\\n",
    "  libaom-dev\n\nFROM base AS geodata\n" => <<~'DOCKER'}
      libaom-dev

    ARG CCACHE_VERSION=4.14
    ARG CCACHE_STORAGE_HTTP_VERSION=0.9
    COPY ccache /usr/bin/ccache
    COPY ccache-storage-http /usr/bin/ccache-storage-http
    RUN chmod 0755 /usr/bin/ccache /usr/bin/ccache-storage-http && \
      ccache --version | grep -F "ccache version ${CCACHE_VERSION}" && \
      ccache-storage-http --version 2>&1 | grep -F "Version: ${CCACHE_STORAGE_HTTP_VERSION}"

    ENV PATH="/usr/lib/ccache:${PATH}"

    FROM base AS geodata
  DOCKER
  replacements.each do |before, after|
    raise "Base-images Dockerfile changed at #{before.inspect}" unless text.scan(Regexp.new(Regexp.escape(before))).length == 1
    text = text.sub(before, after)
  end
end
raise "Dockerfile must not contain BoringCache credentials" if text.include?("CCACHE_REMOTE_STORAGE")
File.write(path, text)
