const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { register, retain } = require('../.github/actions/retain-product-evidence/index.cjs');

test('retention uploads the unchanged final evidence after the product updates it', async () => {
  const state = {};
  const outputs = {};
  const core = { saveState: (key, value) => state[key] = value, setOutput: (key, value) => outputs[key] = value,
    getState: key => state[key], info: () => {} };
  register(core);
  const directory = state['evidence-directory'];
  try {
    const source = path.join(directory, `boringcache-one-evidence-${'a'.repeat(64)}.json`);
    fs.writeFileSync(outputs['registry-path'], source);
    fs.writeFileSync(source, JSON.stringify({ schema_version: 'boringcache_one_evidence.v1', phases: { restore: {} } }));
    const final = JSON.stringify({ schema_version: 'boringcache_one_evidence.v1', phases: { restore: {}, post: { save_status: 'saved' } } });
    fs.writeFileSync(source, final);
    let uploaded = false;
    await retain(core, { uploadArtifact: async (name, files, root, options) => {
      uploaded = true;
      assert.match(name, /^product-boringcache-one-evidence-/);
      assert.equal(fs.readFileSync(files[0], 'utf8'), final);
      assert.equal(root, directory);
      assert.equal(options.retentionDays, 90);
    } });
    assert.ok(uploaded);
    fs.writeFileSync(source, '{}');
    await assert.rejects(retain(core, {}), /schema is unsupported/);
    fs.unlinkSync(source);
    await assert.rejects(retain(core, {}), /ENOENT/);
    fs.writeFileSync(outputs['registry-path'], '');
    await assert.rejects(retain(core, {}), /did not return an evidence path/);
  } finally {
    fs.rmSync(directory, { recursive: true });
  }
});
