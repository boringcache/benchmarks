const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { randomBytes } = require('node:crypto');
const { register, retain } = require('../.github/actions/retain-product-evidence/index.cjs');

test('the Action loads the installed SDKs in main and post execution', () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'evidence-sdk-test-'));
  try {
    const output = path.join(directory, 'output');
    const state = path.join(directory, 'state');
    fs.writeFileSync(output, '');
    fs.writeFileSync(state, '');
    const action = path.resolve(__dirname, '../.github/actions/retain-product-evidence/index.cjs');
    const env = { ...process.env, TMPDIR: directory, TEMP: directory, TMP: directory,
      GITHUB_OUTPUT: output, GITHUB_STATE: state, 'STATE_evidence-directory': '' };
    const main = spawnSync(process.execPath, [action], { env, encoding: 'utf8' });
    assert.equal(main.status, 0, main.stderr);
    const registered = fs.readdirSync(directory).filter(name => name.startsWith('benchmark-evidence-'));
    assert.equal(registered.length, 1);
    const registryDirectory = path.join(directory, registered[0]);
    assert.equal(fs.readFileSync(state, 'utf8').split('\n')[1], registryDirectory);
    assert.equal(fs.readFileSync(path.join(registryDirectory, 'evidence-path'), 'utf8'), '');
    const post = spawnSync(process.execPath, [action], {
      env: { ...env, 'STATE_evidence-directory': registryDirectory }, encoding: 'utf8'
    });
    assert.equal(post.status, 1, post.stderr);
    assert.match(post.stdout, /The product did not return an evidence path/);
    assert.doesNotMatch(post.stderr, /ERR_PACKAGE_PATH_NOT_EXPORTED|ERR_REQUIRE_ESM/);
  } finally {
    fs.rmSync(directory, { recursive: true });
  }
});

test('retention uploads the unchanged final evidence after the product updates it', async () => {
  const state = {};
  const outputs = {};
  const core = { saveState: (key, value) => state[key] = value, setOutput: (key, value) => outputs[key] = value,
    getState: key => state[key], info: () => {} };
  register(core);
  const directory = state['evidence-directory'];
  const source = path.join(os.tmpdir(), `boringcache-one-evidence-${randomBytes(32).toString('hex')}.json`);
  try {
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
    const outside = path.join(directory, path.basename(source));
    fs.writeFileSync(outside, final);
    fs.writeFileSync(outputs['registry-path'], outside);
    await assert.rejects(retain(core, {}), /runner temporary directory/);
    fs.symlinkSync(outside, source);
    fs.writeFileSync(outputs['registry-path'], source);
    await assert.rejects(retain(core, {}), /regular JSON file/);
    fs.writeFileSync(outputs['registry-path'], '');
    await assert.rejects(retain(core, {}), /did not return an evidence path/);
  } finally {
    fs.rmSync(source, { force: true });
    fs.rmSync(directory, { recursive: true });
  }
});

test('post-publication storage is uploaded separately after original evidence', async () => {
  const state = {}, outputs = {};
  const core = { saveState: (key, value) => state[key] = value, setOutput: (key, value) => outputs[key] = value,
    getState: key => state[key] };
  register(core);
  const directory = state['evidence-directory'];
  const source = path.join(os.tmpdir(), `boringcache-one-evidence-${randomBytes(32).toString('hex')}.json`);
  const uploaded = [];
  try {
    const final = JSON.stringify({ schema_version: 'boringcache_one_evidence.v1', phases: { restore: { workspace: 'boringcache/benchmarks' }, post: { save_status: 'saved' } } });
    fs.writeFileSync(source, final);
    fs.writeFileSync(outputs['registry-path'], source);
    const measurement = (_evidence, retained, destination) => {
      assert.equal(uploaded.length, 1);
      assert.equal(fs.readFileSync(retained, 'utf8'), final);
      const target = path.join(destination, 'storage.json');
      fs.writeFileSync(target, JSON.stringify({ kind: 'post-publication-storage' }));
      return target;
    };
    await retain(core, { uploadArtifact: async (name, files) => uploaded.push({ name, files }) }, measurement);
    assert.match(uploaded[0].name, /^product-/);
    assert.match(uploaded[1].name, /^storage-/);
    assert.equal(fs.readFileSync(uploaded[0].files[0], 'utf8'), final);
  } finally {
    fs.rmSync(source, { force: true });
    fs.rmSync(directory, { recursive: true });
  }
});
