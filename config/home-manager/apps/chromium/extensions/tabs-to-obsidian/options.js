import { getSettings, saveSettings, status } from './api.js';

const $ = (id) => document.getElementById(id);

function setStatus(text, kind = '') {
  $('status').textContent = text;
  $('status').className = kind;
}

async function save() {
  const apiUrl = $('apiUrl').value.trim().replace(/\/+$/, '') || 'https://obs.local:27124';
  let origin;
  try {
    origin = new URL(apiUrl).origin;
  } catch {
    return setStatus('That address is not a URL.', 'error');
  }

  // obs.local is allowed by the manifest; any other host needs the user's OK.
  // Requested before any other await, so Brave still sees the click.
  const pattern = `${origin.replace(/:\d+$/, '')}/*`;
  if (!(await chrome.permissions.request({ origins: [pattern] }))) {
    return setStatus(`Brave needs access to ${origin} to talk to Obsidian.`, 'error');
  }

  await saveSettings({ apiUrl, apiKey: $('apiKey').value.trim() });
  setStatus('Testing…');
  try {
    const s = await status();
    if (!s.authenticated) return setStatus('Obsidian is reachable but refused the API key.', 'error');
    setStatus(`Connected to Obsidian ${s.versions?.obsidian ?? ''}.`, 'ok');
  } catch (e) {
    setStatus(e.message, 'error');
  }
}

getSettings().then((s) => {
  $('apiUrl').value = s.apiUrl;
  $('apiKey').value = s.apiKey;
});
$('save').addEventListener('click', save);
