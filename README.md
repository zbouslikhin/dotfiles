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

## TODO

1. Add gcc compiler
2. Replace asdf (Python setup is still manual: `asdf plugin add python && asdf install python latest`)
