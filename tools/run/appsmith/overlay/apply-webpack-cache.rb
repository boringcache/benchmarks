webpack_path = "upstream/app/client/config/webpack.config.js"
webpack = File.read(webpack_path)

unless webpack.include?('key !== "REACT_APP_SENTRY_RELEASE"')
  old_version = "      version: createEnvironmentHash(env.raw),\n"
  new_version = <<~JS.gsub(/^/, "      ")
    version: createEnvironmentHash(
      Object.fromEntries(
        Object.entries(env.raw).filter(
          ([key]) => key !== "REACT_APP_SENTRY_RELEASE",
        ),
      ),
    ),
  JS
  raise "webpack.config.js: expected cache.version line not found" unless webpack.include?(old_version)

  webpack = webpack.sub(old_version, new_version)
end

unless webpack.include?("maxAge:")
  old_store = "      store: \"pack\",\n"
  new_store = "      store: \"pack\",\n      maxAge: 7 * 24 * 60 * 60 * 1000,\n"
  raise "webpack.config.js: expected cache.store line not found" unless webpack.include?(old_store)

  webpack = webpack.sub(old_store, new_store)
end

unless webpack.include?("lockfile: [paths.yarnLockFile]")
  old_config = "        config: [__filename],\n"
  new_config = "        config: [__filename],\n        lockfile: [paths.yarnLockFile],\n"
  raise "webpack.config.js: expected buildDependencies.config line not found" unless webpack.include?(old_config)

  webpack = webpack.sub(old_config, new_config)
end

File.write(webpack_path, webpack)

build_path = "upstream/app/client/scripts/build.js"
build = File.read(build_path)

unless build.include?("compiler.close(")
  old_open = "    compiler.run((err, stats) => {\n"
  new_open = "    const handleBuild = (err, stats) => {\n"
  old_close = <<~JS
          return resolve(resolveArgs);
        });
      });
    }
  JS
  new_close = <<~JS
          return resolve(resolveArgs);
        };

        compiler.run((err, stats) => {
          compiler.close(closeErr => {
            if (closeErr) {
              return reject(closeErr);
            }
            handleBuild(err, stats);
          });
        });
      });
    }
  JS
  raise "scripts/build.js: expected compiler.run opening not found" unless build.include?(old_open)
  raise "scripts/build.js: expected compiler.run closing not found" unless build.include?(old_close)

  build = build.sub(old_open, new_open).sub(old_close, new_close)
  File.write(build_path, build)
end
