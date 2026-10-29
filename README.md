# dotfiles

Home Manager config for macOS, WSL and Ubuntu, used in place from the clone.

## New machine

One command; both are safe to re-run.

**Windows** (PowerShell, no admin needed):
```powershell
irm https://raw.githubusercontent.com/zbouslikhin/dotfiles/main/bootstrap.ps1 | iex
```
It installs or updates WSL (approve one admin prompt), installs Ubuntu, creates your Linux user
(Linux asks for its password, only if the user doesn't exist yet), turns on systemd, then runs the
Linux bootstrap inside it. Ubuntu uses public DNS (1.1.1.1), not the DNS Windows relays, which can
stop answering; internal names on a VPN or company network will not resolve in WSL. If WSL needs a
Windows restart, restart and run it again.

**macOS / Linux:**
```bash
curl -L https://raw.githubusercontent.com/zbouslikhin/dotfiles/main/bootstrap.sh | sh
```
It installs Nix, copies your Windows SSH keys (WSL, if `~/.ssh` doesn't exist yet), clones the repo,
applies the config and makes the Nix zsh your login shell. sudo asks for your password (not on WSL).

The username, clone location and config (`macos`, `wsl` or `ubuntu`) are detected and saved to
`config/home-manager/machine.env`, which is not committed. To choose them yourself, set
`DOTFILES_DIR`, `DOTFILES_HOST` or `DOTFILES_BRANCH` before the first run.

## Updating

Edit the files in the clone, then:

```bash
nh home switch
```

`NH_FLAKE` points at `path:<clone>/config/home-manager`. The `path:` prefix is needed so Nix sees the
gitignored `machine.env`; use it with `home-manager switch --flake` too. Neovim and zellij configs are
symlinked straight into the clone, so their edits apply without a switch.

The Claude Code mods are the private `zaid-mods` repo, cloned over SSH (needs a GitHub SSH key) to
`~/.claude/zaid-mods`. Every switch pulls its latest `main`, never a pinned version, and installs or
updates every mod. Without access to the repo, add `DOTFILES_CLAUDE_MODS="false"` to `machine.env`.

## Languages

[mise](https://mise.jdx.dev) manages language versions, and reads asdf's `.tool-versions` files too.
Node LTS is the default everywhere (`programming/mise/config.nix`). In a project, pin a version with
`mise use node@22` (or `python@3.13`, `go@latest`, `rust@stable`...), which writes `mise.toml`.

## Chromium extensions

Source: `config/home-manager/apps/chromium/extensions`. A switch puts them in
`%LOCALAPPDATA%\chromium-extensions` (WSL) or `~/.local/share/chromium-extensions`.

Once per browser: `brave://extensions` → Developer mode → **Load unpacked** → pick the folder.
After a change: switch (WSL only), then reload the extension.

## Stream Deck

On WSL, a switch installs Claude Agents, a Stream Deck plugin from the private
[streamdeck-workflow](https://github.com/zbouslikhin/streamdeck-workflow) repo: one key per
Claude agent running in herdr. It goes to `%APPDATA%\Elgato\StreamDeck\Plugins`, and Stream Deck
is restarted when the plugin changed. Nothing happens if Stream Deck isn't installed, or if a
development link is in its place.

It's on by default. To turn it off on a machine, add `DOTFILES_STREAMDECK="false"` to
`machine.env`; the private repo is then never fetched. To take a newer plugin:
`nix flake update streamdeck-workflow --flake path:config/home-manager`, then switch.

## TODO

1. Add gcc compiler
2. Python packages and venvs with uv (mise installs Python itself)
