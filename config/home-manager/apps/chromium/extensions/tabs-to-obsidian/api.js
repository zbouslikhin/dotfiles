// Client for the Obsidian "Local REST API" plugin (coddingtonbear/obsidian-local-rest-api).

const DEFAULTS = {
  apiUrl: 'https://obs.local:27124',
  folder: '',
  note: 'Inbox',
  closeAfterSave: false,
};

export async function getSettings() {
  const sync = await chrome.storage.sync.get(DEFAULTS);
  const { apiKey = '' } = await chrome.storage.local.get('apiKey');
  return { ...sync, apiKey };
}

export async function saveSettings({ apiKey, ...rest }) {
  await chrome.storage.sync.set(rest);
  if (apiKey !== undefined) await chrome.storage.local.set({ apiKey });
}

function endpoint(apiUrl, path) {
  return apiUrl.replace(/\/+$/, '') + path;
}

function vaultPath(path) {
  return '/vault/' + path.split('/').filter(Boolean).map(encodeURIComponent).join('/');
}

async function call(method, path, body) {
  const { apiUrl, apiKey } = await getSettings();
  if (!apiKey) throw new Error('No API key yet. Open the extension options and paste it.');
  let res;
  try {
    res = await fetch(endpoint(apiUrl, path), {
      method,
      headers: {
        Authorization: `Bearer ${apiKey}`,
        ...(body !== undefined && { 'Content-Type': 'text/markdown' }),
      },
      body,
    });
  } catch {
    throw new Error(
      `Can't reach Obsidian at ${apiUrl}. Check it is running, and if it uses HTTPS, ` +
        'open that address once in Brave and accept its certificate.'
    );
  }
  if (res.status === 401) throw new Error('Obsidian refused the API key.');
  if (!res.ok) throw new Error(`Obsidian answered ${res.status}: ${await res.text()}`);
  return res;
}

export async function status() {
  return (await call('GET', '/')).json();
}

// Folders of the vault, down to `depth` levels, e.g. ["05. Travels", "05. Travels/Japan"].
export async function listFolders(depth = 2) {
  const out = [];
  async function walk(dir, level) {
    const { files } = await (await call('GET', vaultPath(dir) + '/')).json();
    const dirs = files.filter((f) => f.endsWith('/')).map((f) => dir + f);
    out.push(...dirs.map((d) => d.slice(0, -1)));
    if (level < depth) await Promise.all(dirs.map((d) => walk(d, level + 1)));
  }
  await walk('', 1);
  return out.sort((a, b) => a.localeCompare(b, undefined, { numeric: true }));
}

// Appends to the note, creating it if it does not exist.
export async function append(path, markdown) {
  await call('POST', vaultPath(path), markdown);
}

// Creates the note, or replaces it if it exists.
export async function put(path, markdown) {
  await call('PUT', vaultPath(path), markdown);
}

export async function open(path) {
  await call('POST', '/open' + vaultPath(path).slice('/vault'.length));
}
