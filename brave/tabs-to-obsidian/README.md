# Tabs to Obsidian

A Brave extension that saves tabs into an Obsidian vault through the
[Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) plugin.

- **Save this tab**: appends `- [ ] [Title](url) · date` to a note (default `Inbox.md`),
  with your comment and any text selected on the page underneath.
- **Save all tabs in window**: writes one note, `Tabs 2026-10-25 14h03.md`, with every web
  tab as a checkbox, grouped by site, and opens it in Obsidian. Pinned tabs are saved but never closed.
- **Close tabs once saved**: closes them only after Obsidian has confirmed the write.
- `Alt+Shift+O` opens the popup. The folder field suggests the folders of your vault.

## 1. Obsidian: install Local REST API

1. Settings → Community plugins → Browse → **Local REST API** → Install → Enable.
2. In its settings, copy the **API key**.
3. Obsidian runs on another machine (`obs.local`), so the API must listen beyond localhost:
   - Advanced settings → **Binding Host** → `0.0.0.0`.
   - If Obsidian runs in Docker, publish the port: `27124:27124` (HTTPS) or `27123:27123` (HTTP).
   - Or keep it private and route a reverse-proxy name to it (e.g. `https://obs-api.local` → `obsidian:27124`).
4. Restart the plugin (toggle it off and on).

## 2. Brave: load the extension

1. Go to `brave://extensions`, switch on **Developer mode**.
2. **Load unpacked** → pick this folder.
3. Pin it from the puzzle-piece menu.

## 3. Connect them

1. Open `https://obs.local:27124` once in Brave and accept the certificate warning. The plugin
   uses a self-signed certificate, and the extension can't connect until Brave accepts it.
   To avoid the warning for good, download `https://obs.local:27124/obsidian-local-rest-api.crt`
   and add it to Windows' *Trusted Root Certification Authorities*.
2. Right-click the extension icon → **Options**, paste the API key, click **Save and test**.
   It should say *Connected to Obsidian …*.

If you use a different address (HTTP on 27123, or a proxy name), enter it in Options.
Brave asks once for access to that host.
