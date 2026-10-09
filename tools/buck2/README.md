# Buck2 cache uploads

Buck2 writes a locally run action's result to the remote cache only when that action allows uploads. Every lane of a case uses the same setup, so BoringCache and NativeLink receive the same actions.

Both cases add `overlay/benchmark-platform`, a local execution platform with the remote cache enabled. Its `cache_uploads` setting is off for warm phases, so a warm build only reads.

## buck2-prelude

- `overlay/cache.patch` sets `allow_cache_upload` on the C++ binary, the C++ library and the Rust binary, and `archive_allow_cache_upload` on the C++ library.
- `.buckconfig.local` sets `buck2.default_allow_cache_upload`, which covers actions with no upload preference, such as the Rust library and test.
- Three actions are never uploaded:
  - the two `assert_output` genrules, because the prelude caches only genrules marked to run locally;
  - the C++ library's shared-library link, which the prelude's `link_options` builds with uploads off.

## executorch

- `overlay/cache.patch` changes the Buck2 prelude that the case pins (`cb8b34f6`), not ExecuTorch's own files, so upstream commits cannot break it.
- C++ compile and link actions upload unless a target opts out, archives always upload, and genrules upload without being marked local.
- Python packaging actions are not uploaded. The pinned Buck2 (`2025-06-01`) predates `buck2.default_allow_cache_upload`, and the code-generation genrules that run those Python tools miss whenever the tools are rebuilt.
