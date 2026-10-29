import { getSettings, saveSettings, listFolders, append, put, open } from './api.js';

const $ = (id) => document.getElementById(id);

function setStatus(text, kind = '') {
  $('status').textContent = text;
  $('status').className = kind;
}

const pad = (n) => String(n).padStart(2, '0');
const day = (d) => `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
const time = (d) => `${pad(d.getHours())}:${pad(d.getMinutes())}`;

const linkText = (s) => (s || '').replace(/\s+/g, ' ').replace(/([[\]])/g, '\\$1').trim();
const linkUrl = (u) => u.replace(/ /g, '%20').replace(/\(/g, '%28').replace(/\)/g, '%29');
const link = (tab) => `[${linkText(tab.title) || tab.url}](${linkUrl(tab.url)})`;
const fileName = (s) => s.replace(/[\\/:*?"<>|#^[\]]/g, '-').trim();

function domain(url) {
  try {
    return new URL(url).hostname.replace(/^www\./, '');
  } catch {
    return 'other';
  }
}

async function apiHost() {
  try {
    return new URL((await getSettings()).apiUrl).hostname;
  } catch {
    return '';
  }
}

// Web pages only: no brave://, extension pages, or Obsidian itself.
async function savable(tab) {
  if (!/^https?:/.test(tab.url || '')) return false;
  const host = new URL(tab.url).hostname;
  return host !== 'obs.local' && host !== (await apiHost());
}

function destination() {
  const folder = $('folder').value.trim().replace(/^\/+|\/+$/g, '');
  const note = fileName($('note').value.trim() || 'Inbox').replace(/\.md$/i, '');
  return { folder, note, path: (folder ? folder + '/' : '') + note + '.md' };
}

async function remember() {
  const { folder, note } = destination();
  await saveSettings({ folder, note, closeAfterSave: $('close').checked });
}

async function selectionIn(tab) {
  try {
    const [{ result }] = await chrome.scripting.executeScript({
      target: { tabId: tab.id },
      func: () => getSelection().toString(),
    });
    return (result || '').trim();
  } catch {
    return '';
  }
}

// Closes tabs; if that would empty the window, leaves a new tab so it stays open.
async function closeTabs(tabs) {
  const all = await chrome.tabs.query({ currentWindow: true });
  if (tabs.length >= all.length) await chrome.tabs.create({});
  await chrome.tabs.remove(tabs.map((t) => t.id));
}

async function saveTab() {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  if (!(await savable(tab))) return setStatus('This tab is not a web page.', 'error');

  const { path } = destination();
  const comment = $('comment').value.trim();
  const selection = await selectionIn(tab);
  let md = `\n- [ ] ${link(tab)} · ${day(new Date())}`;
  if (comment) md += `\n\t- ${comment.replace(/\n+/g, ' ')}`;
  if (selection) md += '\n' + selection.split('\n').map((l) => `\t> ${l}`).join('\n');

  await append(path, md);
  await remember();
  setStatus(`Saved to ${path}`, 'ok');
  if ($('close').checked) await closeTabs([tab]);
}

async function saveWindow() {
  const tabs = [];
  for (const t of await chrome.tabs.query({ currentWindow: true })) if (await savable(t)) tabs.push(t);
  if (!tabs.length) return setStatus('No web pages in this window.', 'error');

  const groups = new Map();
  for (const t of tabs) {
    const d = domain(t.url);
    if (!groups.has(d)) groups.set(d, []);
    groups.get(d).push(t);
  }
  const sorted = [...groups].sort((a, b) => b[1].length - a[1].length || a[0].localeCompare(b[0]));

  const now = new Date();
  const title = `Tabs ${day(now)} ${time(now).replace(':', 'h')}`;
  const comment = $('comment').value.trim();
  const lines = [
    '---',
    `created: ${day(now)}T${time(now)}`,
    'source: brave',
    'tags: [tabs]',
    '---',
    `# ${title}`,
    '',
    ...(comment ? [comment, ''] : []),
    `${tabs.length} tabs. Tick a box once you've acted on it, delete the line once it's not worth keeping.`,
  ];
  for (const [d, group] of sorted) {
    lines.push('', `## ${d} (${group.length})`, ...group.map((t) => `- [ ] ${link(t)}`));
  }

  const { folder } = destination();
  const path = (folder ? folder + '/' : '') + fileName(title) + '.md';
  await put(path, lines.join('\n') + '\n');
  await remember();
  setStatus(`Saved ${tabs.length} tabs to ${path}`, 'ok');
  open(path).catch(() => {});
  if ($('close').checked) await closeTabs(tabs.filter((t) => !t.pinned));
}

function guard(fn) {
  return async () => {
    document.querySelectorAll('button').forEach((b) => (b.disabled = true));
    setStatus('Saving…');
    try {
      await fn();
    } catch (e) {
      setStatus(e.message, 'error');
    } finally {
      document.querySelectorAll('button').forEach((b) => (b.disabled = false));
    }
  };
}

async function init() {
  const s = await getSettings();
  $('folder').value = s.folder;
  $('note').value = s.note;
  $('close').checked = s.closeAfterSave;

  const count = (await chrome.tabs.query({ currentWindow: true })).length;
  $('saveWindow').textContent = `Save all ${count} tabs in window`;

  $('saveTab').addEventListener('click', guard(saveTab));
  $('saveWindow').addEventListener('click', guard(saveWindow));
  $('options').addEventListener('click', (e) => {
    e.preventDefault();
    chrome.runtime.openOptionsPage();
  });

  if (!s.apiKey) return setStatus('Set your API key in Settings first.', 'error');
  try {
    const folders = await listFolders();
    $('folders').replaceChildren(...folders.map((f) => new Option(f)));
  } catch (e) {
    setStatus(e.message, 'error');
  }
}

init();
