require "digest"

manifest, *assets = ARGV
abort "usage: verify-checksums.rb SHA256SUMS ASSET..." unless manifest && assets.any?

checksums = File.readlines(manifest, chomp: true).to_h do |line|
  digest, name = line.split(/\s+/, 2)
  [name&.delete_prefix("*"), digest]
end
assets.each do |asset|
  expected = checksums[asset]
  abort "missing SHA256 checksum for #{asset}" unless expected&.match?(/\A[0-9a-f]{64}\z/i)
  abort "SHA256 checksum mismatch for #{asset}" unless Digest::SHA256.file(asset).hexdigest.casecmp?(expected)

  puts "#{asset}: OK"
end
