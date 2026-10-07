prefix = ARGV.fetch(0)
url = "#{ENV.fetch("R2_ENDPOINT")}/#{ENV.fetch("R2_BUCKET")}/#{prefix}/preflight"
auth = ["--aws-sigv4", "aws:amz:auto:s3", "--user", "#{ENV.fetch("NATIVELINK_R2_ACCESS_KEY_ID")}:#{ENV.fetch("NATIVELINK_R2_SECRET_ACCESS_KEY")}"]
steps = [["--upload-file", File::NULL], ["--output", File::NULL]]
exit steps.all? { system("curl", "--fail", "--silent", "--show-error", *auth, *it, url) }
