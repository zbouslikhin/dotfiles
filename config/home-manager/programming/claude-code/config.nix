{
  config,
  lib,
  claude-mods,
  ...
}:

# Claude Code mods: the private claude-mods repo, a flake input fetched over SSH. Change them in
# their own clone and push, then `nix flake update claude-mods --flake path:config/home-manager`
# and switch. Turn them off per machine with DOTFILES_CLAUDE_MODS="false" in machine.env (say,
# without access to the repo); then it isn't fetched.
{
  options.dotfiles.claudeMods.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Install the Claude Code mods from the private claude-mods repo.";
  };

  config = lib.mkIf config.dotfiles.claudeMods.enable {
    # A fixed path to the store copy: the zaid-mods marketplace is registered here, so a newer
    # copy only moves the link.
    home.file.".claude/zaid-mods".source = "${claude-mods}";

    home.activation.claudeMods = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      # Registers the marketplace and installs every mod; bootstrap.sh runs it once claude exists.
      if [ -x "$HOME/.local/bin/claude" ]; then
        PATH="$HOME/.local/bin:$PATH" run sh "$HOME/.claude/zaid-mods/install.sh" ||
          warnEcho "Couldn't install the Claude Code mods."
        # install.sh copies switches.json out of the read-only store; /mods has to write it.
        if [ -f "$HOME/.claude/mods/switches.json" ]; then
          run chmod u+w "$HOME/.claude/mods/switches.json"
        fi
      fi
    '';
  };
}
