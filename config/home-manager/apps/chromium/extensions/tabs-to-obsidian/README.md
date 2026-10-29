# Tabs to Obsidian

Saves the current tab, or every tab in the window, into Obsidian through the
[Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) plugin.
`Alt+Shift+O` opens it.

## Setup

1. **Obsidian**: install and enable **Local REST API**, copy its API key, set
   Advanced settings → Binding Host → `0.0.0.0`, then toggle the plugin off and on.
   In Docker, publish `27124:27124`.
2. **Brave**: load this folder unpacked (see the dotfiles README).
3. Open `https://obs.local:27124` once in Brave and accept the certificate.
4. Extension **Options**: paste the API key → **Save and test**.
   For another address (HTTP on 27123, a proxy name), change it there.
