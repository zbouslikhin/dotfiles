# dotfiles

Home Manager config for macOS, WSL and Ubuntu, used in place from the clone.

## New machine

1. **Windows only:** install WSL and open Ubuntu:
   ```bash
   wsl --install
   ```
2. Run the bootstrap:
   ```bash
   curl -L https://raw.githubusercontent.com/zbouslikhin/dotfiles/main/bootstrap.sh | sh
   ```

It installs Nix if needed, copies your Windows SSH keys (WSL), clones the repo, applies the config and
makes the Nix zsh your login shell. It is safe to re-run.

It asks for the username, the clone location and the config (`macos`, `wsl` or `ubuntu`, detected
by default) and saves them to `config/home-manager/machine.env`, which is not committed. To skip the
questions, set `DOTFILES_USER`, `DOTFILES_DIR`, `DOTFILES_HOST` or `DOTFILES_BRANCH` before `sh`.

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
