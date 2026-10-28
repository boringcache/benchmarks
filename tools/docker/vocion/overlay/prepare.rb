source = File.read("upstream/packages/core/Dockerfile")
image = "public.ecr.aws/docker/library/node:20-alpine"
replacement = "docker.io/library/node:20-alpine@sha256:fb4cd12c85ee03686f6af5362a0b0d56d50c58a04632e6c0fb8363f609372293"
pattern = /^FROM #{Regexp.escape(image)} AS (deps|builder|runner)$/
raise "Vocion Node image stages changed" unless source.scan(pattern).flatten.sort == %w[builder deps runner]

File.write("overlay/Dockerfile", source.gsub(pattern) { "FROM #{replacement} AS #{$1}" })
