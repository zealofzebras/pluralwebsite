import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../static/js/theme.js', import.meta.url), 'utf8');

function boot({ saved = null, dark = false, blocked = false } = {}) {
  const events = {};
  const mediaEvents = {};
  const selectEvents = {};
  const root = { dataset: {} };
  const meta = { content: '' };
  const control = { hidden: true };
  const storage = new Map(saved === null ? [] : [['plural-theme', saved]]);
  const select = { value: '', closest: () => control, addEventListener: (name, callback) => { selectEvents[name] = callback; } };
  const media = { matches: dark, addEventListener: (name, callback) => { mediaEvents[name] = callback; } };
  const checkStorage = () => { if (blocked) throw new Error('Storage is unavailable'); };
  runInNewContext(source, {
    matchMedia: () => media,
    document: {
      documentElement: root,
      querySelector: () => meta,
      getElementById: () => select,
      addEventListener: (name, callback) => { events[name] = callback; },
    },
    localStorage: {
      getItem: key => { checkStorage(); return storage.get(key) ?? null; },
      setItem: (key, value) => { checkStorage(); storage.set(key, value); },
      removeItem: key => { checkStorage(); storage.delete(key); },
    },
  });
  events.DOMContentLoaded();
  return {
    root, meta, control, select, storage,
    choose(value) { select.value = value; selectEvents.change(); },
    system(darkMode) { media.matches = darkMode; mediaEvents.change(); },
  };
}

test('System is the default and follows live system changes', () => {
  const site = boot({ dark: true });
  assert.equal(site.root.dataset.theme, 'system');
  assert.equal(site.select.value, 'system');
  assert.equal(site.control.hidden, false);
  assert.equal(site.meta.content, '#141b18');
  site.system(false);
  assert.equal(site.meta.content, '#f4f7f5');
});

test('Explicit themes are remembered and override the system', () => {
  const site = boot({ saved: 'light', dark: true });
  assert.equal(site.meta.content, '#f4f7f5');
  site.choose('dark');
  assert.equal(site.storage.get('plural-theme'), 'dark');
  site.system(false);
  assert.equal(site.meta.content, '#141b18');
  const reloaded = boot({ saved: site.storage.get('plural-theme') });
  assert.equal(reloaded.root.dataset.theme, 'dark');
  site.choose('system');
  assert.equal(site.storage.has('plural-theme'), false);
  assert.equal(site.meta.content, '#f4f7f5');
});

test('Unavailable storage does not prevent switching', () => {
  const site = boot({ blocked: true });
  site.choose('dark');
  assert.equal(site.root.dataset.theme, 'dark');
  assert.equal(site.meta.content, '#141b18');
  site.choose('system');
  site.system(true);
  assert.equal(site.meta.content, '#141b18');
});

test('Invalid saved preferences fall back to System', () => {
  assert.equal(boot({ saved: 'invalid' }).root.dataset.theme, 'system');
});