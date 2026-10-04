const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

function register(core) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'benchmark-evidence-'));
  const registry = path.join(directory, 'evidence-path');
  fs.writeFileSync(registry, '', { mode: 0o600 });
  core.saveState('evidence-directory', directory);
  core.setOutput('registry-path', registry);
}

async function retain(core, artifact) {
  const directory = core.getState('evidence-directory');
  const source = fs.readFileSync(path.join(directory, 'evidence-path'), 'utf8').trim();
  if (!source) {
    throw new Error('The product did not return an evidence path.');
  }
  const name = path.basename(source);
  if (!/^boringcache-one-evidence-[a-f0-9]{64}\.json$/.test(name)) {
    throw new Error('The product returned an unexpected evidence filename.');
  }
  const stat = fs.lstatSync(source);
  if (!stat.isFile() || stat.size > 8 * 1024 * 1024) {
    throw new Error('Product evidence must be a regular JSON file no larger than 8 MiB.');
  }
  const content = fs.readFileSync(source);
  const evidence = JSON.parse(content);
  if (evidence.schema_version !== 'boringcache_one_evidence.v1' || !evidence.phases) {
    throw new Error('The product evidence schema is unsupported.');
  }
  const target = path.join(directory, name);
  fs.writeFileSync(target, content, { mode: 0o600 });
  await artifact.uploadArtifact(`product-${name.slice(0, -5)}`, [target], directory, { retentionDays: 90 });
}

module.exports = { register, retain };

if (require.main === module) {
  import('@actions/core').then(async core => {
    try {
      if (core.getState('evidence-directory')) {
        const { DefaultArtifactClient } = await import('@actions/artifact');
        await retain(core, new DefaultArtifactClient());
      } else {
        register(core);
      }
    } catch (error) {
      core.setFailed(`Product evidence was not retained: ${error.message}`);
    }
  }).catch(error => {
    console.error(`Evidence dependencies could not be loaded: ${error.message}`);
    process.exitCode = 1;
  });
}
