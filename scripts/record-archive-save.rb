require "json"

path, key, hit = ARGV
record = JSON.parse(File.read(path))
if hit == "true"
  record["cache_saved_key"] = key
else
  record["excluded"] ||= "GitHub Actions Cache could not confirm #{key} after the save. #{record.fetch("run_url")}"
end
File.write(path, JSON.pretty_generate(record) + "\n")
abort record.fetch("excluded") unless hit == "true"
