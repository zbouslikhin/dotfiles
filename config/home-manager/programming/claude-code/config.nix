{
  config,
  pkgs,
  lib,
  hmDir,
  ...
}:

# Claude Code mods (the private claude-mods repo), kept here as a git submodule.
let
  mods = "${hmDir}/programming/claude-code/zaid-mods";
in
{
  # A symlink into the clone, so mod edits apply without a switch. The zaid-mods marketplace is
  # registered at this path.
  home.file.".claude/zaid-mods".source = config.lib.file.mkOutOfStoreSymlink mods;

  home.activation.claudeMods = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    # The submodule is private, so this needs a GitHub SSH key; skipped without one.
    if [ ! -f ${lib.escapeShellArg mods}/install.sh ]; then
      GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -o BatchMode=yes" \
        run ${lib.getExe pkgs.git} -C ${lib.escapeShellArg mods}/.. submodule update --init zaid-mods ||
        warnEcho "Skipped the Claude Code mods: no access to the private claude-mods repo."
    fi
    # Registers the marketplace and installs every mod; bootstrap.sh runs it once claude exists.
    if [ -x "$HOME/.local/bin/claude" ] && [ -f "$HOME/.claude/zaid-mods/install.sh" ]; then
      PATH="$HOME/.local/bin:$PATH" run sh "$HOME/.claude/zaid-mods/install.sh" ||
        warnEcho "Couldn't install the Claude Code mods."
    fi
  '';
}
