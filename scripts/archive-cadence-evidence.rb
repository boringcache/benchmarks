require 'json'
require 'digest'
require 'fileutils'
require 'open3'
require File.join(Dir.pwd, 'scripts/benchmark-evidence')
$stdout.sync = true
repository = 'boringcache/benchmarks'
release = 'evidence-cadence-2026-10-05'
base_url = "https://github.com/#{repository}/releases/download/#{release}"
archive_root = '/tmp/cadence-archives'
download_root = '/tmp/cadence-archives-downloaded'
index_path = '/tmp/cadence-archive-index.json'
FileUtils.mkdir_p([archive_root, download_root])
run = ->(*args) do
  output, error, status = Open3.capture3(*args)
  raise "#{args.first}: #{error}" unless status.success?
  output
end
publish = ->(path) do
  name = File.basename(path)
  assets = JSON.parse(run.call('gh', 'release', 'view', release, '--repo', repository, '--json', 'assets')).fetch('assets')
  run.call('gh', 'release', 'upload', release, path, '--repo', repository) unless assets.any? { |asset| asset.fetch('name') == name }
  target = File.join(download_root, name)
  run.call('gh', 'release', 'download', release, '--repo', repository, '--pattern', name, '--dir', download_root) unless File.exist?(target)
  sha = Digest::SHA256.file(path).hexdigest
  raise "Published file differs: #{name}" unless Digest::SHA256.file(target).hexdigest == sha
  {'name' => name, 'url' => "#{base_url}/#{name}", 'bytes' => File.size(path), 'sha256' => sha}
end
ARGV.each do |id|
  rows = File.exist?(index_path) ? JSON.parse(File.read(index_path)) : []
  next if rows.any? { |row| row['run_id'].to_s == id }
  directory = "/tmp/cadence-evidence-#{id}"
  manifest = JSON.parse(File.read(File.join(directory, 'manifest.json')))
  raise "Incomplete export #{id}" unless BenchmarkEvidence.verify(directory)['state'] == 'complete'
  name = "benchmarks-#{id}.tar.gz"
  archive = File.join(archive_root, name)
  run.call('tar', '-czf', archive, '-C', directory, '.') unless File.exist?(archive)
  parts = []
  File.open(archive, 'rb') do |input|
    number = 0
    until input.eof?
      number += 1
      part = File.join(archive_root, format('%s.part%03d', name, number))
      File.open(part, 'wb') { |output| IO.copy_stream(input, output, 1_900_000_000) }
      parts << publish.call(part)
      puts "Published and verified #{File.basename(part)}"
      FileUtils.rm_f(part)
    end
  end
  descriptor = {'schema_version' => 1, 'format' => 'split-tar-gzip', 'archive_name' => name,
    'archive_bytes' => File.size(archive), 'archive_sha256' => Digest::SHA256.file(archive).hexdigest,
    'reconstruction' => 'Download all parts, verify each SHA-256, concatenate them in listed order, verify the archive SHA-256, then extract the tar.gz archive.',
    'parts' => parts}
  descriptor_path = File.join(archive_root, "#{name}.json")
  File.write(descriptor_path, JSON.pretty_generate(descriptor) + "\n")
  published = publish.call(descriptor_path)
  FileUtils.rm_f(archive)
  Dir.children(directory).reject { |entry| entry == 'manifest.json' }.each do |entry|
    FileUtils.rm_rf(File.join(directory, entry))
  end
  reconstructed = File.join(download_root, name)
  File.open(reconstructed, 'wb') do |output|
    parts.each { |part| File.open(File.join(download_root, part.fetch('name')), 'rb') { |input| IO.copy_stream(input, output) } }
  end
  raise "Reconstructed archive differs #{id}" unless Digest::SHA256.file(reconstructed).hexdigest == descriptor.fetch('archive_sha256')
  extracted = File.join(download_root, id)
  FileUtils.mkdir_p(extracted)
  run.call('tar', '-xzf', reconstructed, '-C', extracted)
  verified = BenchmarkEvidence.verify(extracted)
  raise "Published inventory failed #{id}" unless verified['state'] == 'complete'
  rows = File.exist?(index_path) ? JSON.parse(File.read(index_path)) : []
  rows << {'repository' => repository, 'run_id' => id.to_i, 'verified_files' => verified.fetch('verified_files'),
    'gaps' => [], 'inventory_state' => 'complete', 'bundle_format' => 'split-tar-gzip-index',
    'bundle_url' => published.fetch('url'), 'bundle_bytes' => published.fetch('bytes'), 'sha256' => published.fetch('sha256'),
    'archive_bytes' => descriptor.fetch('archive_bytes'), 'archive_sha256' => descriptor.fetch('archive_sha256'), 'bundle_parts' => parts,
    'release_url' => "https://github.com/#{repository}/releases/tag/#{release}", 'verified_on' => '2026-10-05',
    'publication_verification' => 'Downloaded the published index and every part, verified their SHA-256 values, reconstructed and verified the archive, then verified every listed file and the run inventory',
    'scope' => manifest.fetch('scope')}
  File.write(index_path, JSON.pretty_generate(rows.sort_by { |row| row.fetch('run_id') }) + "\n")
  puts "Archived and reverified #{id}: #{verified.fetch('verified_files')} files in #{parts.length} parts"
end
