# dotfiles

Home Manager config for macOS, WSL and Ubuntu, used in place from the clone.

## New machine

One command; both are safe to re-run.

**Windows** (PowerShell, no admin needed):
```powershell
irm https://raw.githubusercontent.com/zbouslikhin/dotfiles/main/bootstrap.ps1 | iex
```
It installs or updates WSL (approve one admin prompt), installs Ubuntu, creates your Linux user (asks
for its password once, only if the user doesn't exist yet), turns on systemd, then runs the Linux
bootstrap inside it. If Windows needs a restart for WSL, setup carries on by itself after you sign in.

**macOS / Linux:**
```bash
curl -L https://raw.githubusercontent.com/zbouslikhin/dotfiles/main/bootstrap.sh | sh
```
It asks for your sudo password once, then installs Nix, copies your Windows SSH keys (WSL), clones the
repo, applies the config and makes the Nix zsh your login shell.

No other questions are asked. The username, clone location and config (`macos`, `wsl` or `ubuntu`)
are detected and saved to `config/home-manager/machine.env`, which is not committed. To override them,
set `DOTFILES_USER`, `DOTFILES_DIR`, `DOTFILES_HOST` or `DOTFILES_BRANCH` first (on Windows also
`DOTFILES_DISTRO`, the WSL distro name).

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
