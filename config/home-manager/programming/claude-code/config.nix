{
  config,
  pkgs,
  lib,
  ...
}:

# Claude Code mods: the private zaid-mods repo, cloned to ~/.claude/zaid-mods over SSH and pulled to
# the latest main on every switch; never pinned. Turn them off per machine with
# DOTFILES_CLAUDE_MODS="false" in machine.env (say, without access to the repo).
{
  options.dotfiles.claudeMods.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Install the Claude Code mods from the private zaid-mods repo.";
  };

  config = lib.mkIf config.dotfiles.claudeMods.enable {
    home.activation.claudeMods = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      mods="$HOME/.claude/zaid-mods"
      git=${lib.getExe pkgs.git}
      export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -o BatchMode=yes"
      if [ -d "$mods/.git" ]; then
        run $git -C "$mods" pull --ff-only --quiet ||
          warnEcho "Couldn't pull the latest Claude Code mods into $mods; kept the version there."
      elif [ ! -e "$mods" ]; then
        run $git clone --quiet git@github.com:zbouslikhin/zaid-mods.git "$mods" ||
          warnEcho "Skipped the Claude Code mods: no access to the private zaid-mods repo."
      else
        warnEcho "$mods isn't a git clone; move it away to get the Claude Code mods."
      fi
      unset GIT_SSH_COMMAND
      # Registers the marketplace and installs or updates every mod; bootstrap.sh runs it once
      # claude exists.
      if [ -x "$HOME/.local/bin/claude" ] && [ -f "$mods/install.sh" ]; then
        PATH="$HOME/.local/bin:$PATH" run sh "$mods/install.sh" ||
          warnEcho "Couldn't install the Claude Code mods."
        # An earlier switch copied switches.json out of the read-only store; /mods has to write it.
        if [ -f "$HOME/.claude/mods/switches.json" ]; then
          run chmod u+w "$HOME/.claude/mods/switches.json"
        fi
      fi
    '';
  };
}
