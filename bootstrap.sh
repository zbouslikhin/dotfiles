#!/bin/sh
# Set up a new machine in one command; safe to re-run.
#
#   curl -L https://raw.githubusercontent.com/zbouslikhin/dotfiles/main/bootstrap.sh | sh
#
# On Windows use bootstrap.ps1 instead; it sets up WSL and then runs this.
# Optional overrides, used on the first run only (later runs read machine.env):
#   DOTFILES_DIR     where the repo is cloned   (default: ~/dotfiles)
#   DOTFILES_HOST    macos | wsl | ubuntu       (default: detected)
#   DOTFILES_BRANCH  branch to clone            (default: main)
#   DOTFILES_REPO    URL to clone from          (default: GitHub over HTTPS)
set -eu
# home-manager and nh need $USER, which some shells leave unset.
export USER="${USER:-$(id -un)}"

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
env_file="$DOTFILES_DIR/config/home-manager/machine.env"
info() { printf '\033[0;34m==> %s\033[0m\n' "$*"; }

# --- 1. Which config: saved by an earlier run, else detected ------------------
if [ -f "$env_file" ]; then
  . "$env_file"
elif [ "$(uname -s)" = Darwin ]; then
  DOTFILES_HOST="${DOTFILES_HOST:-macos}"
elif [ -n "${WSL_DISTRO_NAME:-}" ]; then
  DOTFILES_HOST="${DOTFILES_HOST:-wsl}"
else
  DOTFILES_HOST="${DOTFILES_HOST:-ubuntu}"
fi
info "Config: $DOTFILES_HOST, user: $USER, repo: $DOTFILES_DIR"

# --- 2. SSH keys from Windows (WSL, first run only) ---------------------------
if [ "$DOTFILES_HOST" = wsl ] && [ ! -d "$HOME/.ssh" ]; then
  win_ssh="/mnt/c/Users/$(/mnt/c/Windows/System32/cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')/.ssh"
  if [ -d "$win_ssh" ]; then
    info "Copying SSH keys from $win_ssh"
    cp -r "$win_ssh" "$HOME/.ssh"
    chmod -R go= "$HOME/.ssh"
  fi
fi

# --- 3. Nix --------------------------------------------------------------------
nix_profile=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
if [ ! -f "$nix_profile" ]; then
  info "Installing Nix"
  curl -sSfL https://install.determinate.systems/nix | sh -s -- install --no-confirm
fi
. "$nix_profile"

# --- 4. The repo ---------------------------------------------------------------
# A new machine may have no git; Nix can provide it.
command -v git >/dev/null || git() { nix run nixpkgs#git -- "$@"; }
if [ -d "$DOTFILES_DIR/.git" ]; then
  git -C "$DOTFILES_DIR" pull --ff-only || info "Could not update the repo; using it as it is."
else
  git clone --branch "${DOTFILES_BRANCH:-main}" \
    "${DOTFILES_REPO:-https://github.com/zbouslikhin/dotfiles.git}" "$DOTFILES_DIR"
  # Fetch over HTTPS (works without keys), push over SSH.
  git -C "$DOTFILES_DIR" remote set-url --push origin git@github.com:zbouslikhin/dotfiles.git
fi
cat >"$env_file" <<EOF
DOTFILES_USER="$USER"
DOTFILES_DIR="$DOTFILES_DIR"
DOTFILES_HOST="$DOTFILES_HOST"
EOF

# --- 5. Apply the config -------------------------------------------------------
# path: so Nix sees the gitignored machine.env.
info "Applying the home-manager config"
nix run home-manager/master -- switch -b "backup-$(date +%s)" \
  --flake "path:$DOTFILES_DIR/config/home-manager#$USER"
# Download the default language versions (Node LTS...) set in programming/mise.
"$HOME/.nix-profile/bin/mise" install

# --- 6. Nix zsh as the login shell ---------------------------------------------
zsh_path="$HOME/.nix-profile/bin/zsh"
grep -qx "$zsh_path" /etc/shells || echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
[ "${SHELL:-}" = "$zsh_path" ] || sudo chsh -s "$zsh_path" "$USER"

# --- 7. Claude Code and its mods -----------------------------------------------
# Anthropic's installer, which keeps claude up to date by itself.
export PATH="$HOME/.local/bin:$PATH"
if ! command -v claude >/dev/null; then
  info "Installing Claude Code"
  curl -fsSL https://claude.ai/install.sh | bash
fi
# The mods (the claude-mods flake input) are linked to ~/.claude/zaid-mods by the switch above,
# which installs them too once claude exists; on the first run it doesn't yet, so install them here.
# install.sh copies switches.json out of the read-only store, and /mods has to write it.
mods="$HOME/.claude/zaid-mods"
if [ -f "$mods/install.sh" ]; then
  sh "$mods/install.sh"
  chmod u+w "$HOME/.claude/mods/switches.json" 2>/dev/null || true
fi
# File tree side pane (public mod): https://github.com/data-goblin/claude-code-filetree
# HTTPS, not the owner/repo shorthand, which clones over SSH when a key exists.
claude plugin marketplace add https://github.com/data-goblin/claude-code-filetree.git ||
  claude plugin marketplace update claude-code-filetree
claude plugin install filetree@claude-code-filetree
# Lets herdr show each Claude session's state (adds a hook to ~/.claude/settings.json).
herdr integration install claude

info "Done. Open a new terminal. Update later with: nh home switch"
