#!/bin/sh
# Set up a new machine in one command; safe to re-run.
#
#   curl -L https://raw.githubusercontent.com/zbouslikhin/dotfiles/main/bootstrap.sh | sh
#
# Overrides (export before running, or put before `sh`):
#   DOTFILES_USER    login name the config is built for   (default: current user)
#   DOTFILES_DIR     where the repo is cloned             (default: ~/dotfiles)
#   DOTFILES_HOST    macos | wsl | ubuntu                 (default: detected)
#   DOTFILES_BRANCH  branch for the first clone           (default: main)
#   DOTFILES_REPO    URL to clone from                    (default: GitHub over HTTPS)
set -eu
# home-manager and nh need $USER, which some shells (docker exec, cron) leave unset.
USER="${USER:-$(id -un)}"
export USER

REPO_HTTPS="https://github.com/zbouslikhin/dotfiles.git"
DOTFILES_REPO="${DOTFILES_REPO:-$REPO_HTTPS}"
REPO_SSH="git@github.com:zbouslikhin/dotfiles.git"

info() { printf '\033[0;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[0;33m!!  %s\033[0m\n' "$*" >&2; }
die() {
  printf '\033[0;31mxx  %s\033[0m\n' "$*" >&2
  exit 1
}

# Under `curl | sh` stdin is the script, so prompts read from the terminal.
# /dev/tty exists even without one, so check it can actually be opened.
has_tty() { (: </dev/tty) 2>/dev/null; }

ask() {
  # ask <prompt> <default>
  if has_tty; then
    printf '%s [%s]: ' "$1" "$2" >/dev/tty
    read -r reply </dev/tty || reply=""
    printf '%s' "${reply:-$2}"
  else
    printf '%s' "$2"
  fi
}

# --- 1. Detect OS, WSL and the matching config --------------------------------
case "$(uname -s)" in
Darwin) detected_host=macos ;;
Linux)
  # Not /proc/version: containers on Docker Desktop share the WSL2 kernel.
  if [ -n "${WSL_DISTRO_NAME:-}" ] || [ -e /proc/sys/fs/binfmt_misc/WSLInterop ] ||
    [ -e /proc/sys/fs/binfmt_misc/WSLInterop-late ]; then
    detected_host=wsl
  else
    detected_host=ubuntu
  fi
  ;;
*) die "Unsupported OS: $(uname -s)" ;;
esac

# Settings saved by an earlier run win over defaults, explicit overrides win over both.
default_dir="${DOTFILES_DIR:-$HOME/dotfiles}"
env_file="$default_dir/config/home-manager/machine.env"
if [ -f "$env_file" ]; then
  saved_user=$(sed -n 's/^DOTFILES_USER=//p' "$env_file")
  saved_dir=$(sed -n 's/^DOTFILES_DIR=//p' "$env_file")
  saved_host=$(sed -n 's/^DOTFILES_HOST=//p' "$env_file")
  DOTFILES_USER="${DOTFILES_USER:-$saved_user}"
  DOTFILES_DIR="${DOTFILES_DIR:-$saved_dir}"
  DOTFILES_HOST="${DOTFILES_HOST:-$saved_host}"
else
  DOTFILES_USER="${DOTFILES_USER:-$(ask 'Username for the config' "$(id -un)")}"
  DOTFILES_DIR="${DOTFILES_DIR:-$(ask 'Clone the repo to' "$default_dir")}"
  DOTFILES_HOST="${DOTFILES_HOST:-$(ask 'Config (macos/wsl/ubuntu)' "$detected_host")}"
fi
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"

case "$DOTFILES_HOST" in
macos | wsl | ubuntu) ;;
*) die "DOTFILES_HOST must be macos, wsl or ubuntu, got '$DOTFILES_HOST'" ;;
esac
[ "$DOTFILES_USER" = "$(id -un)" ] ||
  warn "DOTFILES_USER ($DOTFILES_USER) is not the current user ($(id -un)); the switch will likely fail."

info "Config: $DOTFILES_HOST, user: $DOTFILES_USER, repo: $DOTFILES_DIR"

# --- 2. Install Nix if missing -------------------------------------------------
load_nix() {
  for f in /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh "$HOME/.nix-profile/etc/profile.d/nix.sh"; do
    # shellcheck disable=SC1090
    [ -f "$f" ] && . "$f" && return 0
  done
  return 0
}

load_nix
if command -v nix >/dev/null 2>&1; then
  info "Nix already installed"
else
  info "Installing Nix (Determinate installer, flakes enabled)"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix |
    sh -s -- install --no-confirm
  load_nix
  command -v nix >/dev/null 2>&1 || die "Nix installed but not on PATH; open a new shell and re-run."
fi

# --- 3. SSH keys (WSL) and the repo -------------------------------------------
if [ "$DOTFILES_HOST" = wsl ]; then
  win_user=$(/mnt/c/Windows/System32/cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r' || true)
  win_ssh="/mnt/c/Users/$win_user/.ssh"
  if [ -n "$win_user" ] && [ -d "$win_ssh" ]; then
    info "Copying SSH keys from $win_ssh (existing files are kept)"
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    for src in "$win_ssh"/*; do
      [ -f "$src" ] || continue
      dest="$HOME/.ssh/$(basename "$src")"
      [ -e "$dest" ] && continue
      cp "$src" "$dest"
      case "$dest" in
      *.pub | */known_hosts* | */config) chmod 644 "$dest" ;;
      *) chmod 600 "$dest" ;;
      esac
    done
  else
    warn "No Windows SSH folder found at $win_ssh; skipping key copy."
  fi
fi

# git may be missing on a new machine; Nix can provide it.
if command -v git >/dev/null 2>&1 && git --version >/dev/null 2>&1; then
  git() { command git "$@"; }
else
  git() { nix run nixpkgs#git -- "$@"; }
fi

if [ -d "$DOTFILES_DIR/.git" ]; then
  info "Repo already at $DOTFILES_DIR"
  if [ -z "$(git -C "$DOTFILES_DIR" status --porcelain --untracked-files=no)" ]; then
    git -C "$DOTFILES_DIR" pull --ff-only || warn "Could not fast-forward; using the checkout as it is."
  else
    warn "Repo has local changes; not pulling."
  fi
else
  [ -e "$DOTFILES_DIR" ] && die "$DOTFILES_DIR exists but is not a git repo."
  info "Cloning $DOTFILES_REPO ($DOTFILES_BRANCH) to $DOTFILES_DIR"
  git clone --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR"
fi
# Push over SSH once a key is available.
if [ "$DOTFILES_REPO" = "$REPO_HTTPS" ] && ls "$HOME"/.ssh/id_* >/dev/null 2>&1; then
  git -C "$DOTFILES_DIR" remote set-url origin "$REPO_SSH"
fi

hm_dir="$DOTFILES_DIR/config/home-manager"
env_file="$hm_dir/machine.env"
cat >"$env_file" <<EOF
# Written by bootstrap.sh; per machine, not committed.
DOTFILES_USER=$DOTFILES_USER
DOTFILES_DIR=$DOTFILES_DIR
DOTFILES_HOST=$DOTFILES_HOST
EOF
info "Wrote $env_file"

# --- 4. Apply the Home Manager config ------------------------------------------
# path: makes Nix include the gitignored machine.env.
info "Switching to home-manager config '$DOTFILES_USER' ($DOTFILES_HOST)"
nix run home-manager/master -- switch -b "hm-backup-$(date +%Y%m%d%H%M%S)" \
  --flake "path:$hm_dir#$DOTFILES_USER"

# --- 5. Make the Nix zsh the login shell ---------------------------------------
zsh_path=""
for p in "$HOME/.nix-profile/bin/zsh" "$HOME/.local/state/nix/profile/bin/zsh" \
  "/etc/profiles/per-user/$DOTFILES_USER/bin/zsh"; do
  [ -x "$p" ] && zsh_path="$p" && break
done
[ -n "$zsh_path" ] || die "zsh not found in the Nix profile after the switch."

if ! grep -qxF "$zsh_path" /etc/shells; then
  info "Adding $zsh_path to /etc/shells (needs sudo)"
  echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
fi

if [ "$DOTFILES_HOST" = macos ]; then
  current_shell=$(dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '{print $2}' || true)
else
  current_shell=$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f7 || true)
fi
if [ "$current_shell" != "$zsh_path" ]; then
  info "Changing login shell to $zsh_path"
  # chsh asks for the password on stdin, which is the script under `curl | sh`.
  if has_tty; then
    chsh -s "$zsh_path" </dev/tty || warn "chsh failed; run: chsh -s $zsh_path"
  else
    chsh -s "$zsh_path" || warn "chsh failed; run: chsh -s $zsh_path"
  fi
fi

info "Done. Open a new terminal. Update later with: nh home switch"
