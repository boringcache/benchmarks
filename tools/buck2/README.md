# Buck2 cache uploads

Buck2 writes a locally run action's result to the remote cache only when that action allows uploads. Every lane of a case uses the same setup, so BoringCache and NativeLink receive the same actions.

`overlay/benchmark-platform` is a local execution platform with the remote cache enabled. Its `cache_uploads` setting is off for warm phases, so a warm build only reads.

## executorch

- `overlay/cache.patch` changes the Buck2 prelude that the case pins (`cb8b34f6`), not ExecuTorch's own files, so upstream commits cannot break it.
- C++ compile and link actions upload unless a target opts out, archives always upload, and genrules upload without being marked local.
- Python packaging actions are not uploaded. The pinned Buck2 (`2025-06-01`) predates `buck2.default_allow_cache_upload`, and the code-generation genrules that run those Python tools miss whenever the tools are rebuilt.
