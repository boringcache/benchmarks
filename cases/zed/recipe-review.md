# Zed recipe contracts

The Cargo layer proof pins adjacent source revisions
`5313741ffaa73955ccf5b7cb2c8e15e61d9f92d3` and
`ee3b5558c581429633937e458fad8d109f29e9ee`. Both use Rust 1.97.1 and the same
`script/bundle-linux`. The separate rolling recipe pins Rust 1.98.1 and a newer
bundle script. Its `recipe-contract.json` must not be used to validate the older
layer experiment.

`cargo-layer-recipe.json` records the reviewed older toolchain and bundle digests.
The shared verifier checks those files and all eight active layer plans' Cargo
commands. Primary and remote-server operations preserve the bundle's separate
Cargo invocations, target triples, package selection, bundle configuration, and
declared linker flags. `prepare-zed-lane.sh` selects this contract for both the
cold seed and changed-source consumers. The root rolling contract is retained.

This is a projection of the release build operations. The layer proof verifies
the three release executables, excludes dependency and toolchain setup from its
timer, and does not execute the bundle's packaging, signing, or release upload
steps. It does not establish a complete published application bundle or a
provider performance comparison. Full live qualification remains required.
