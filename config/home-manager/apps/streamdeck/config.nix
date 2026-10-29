{
  config,
  pkgs,
  lib,
  wsl,
  streamdeck-workflow,
  ...
}:

# Claude Agents, a Stream Deck plugin (github.com/zbouslikhin/streamdeck-workflow, private):
# one key per Claude agent running in herdr, coloured by state; press to jump to it,
# hold to rename it. Windows only (Stream Deck runs there, herdr in WSL), so a switch
# on WSL copies it into Stream Deck's plugins. Turn it off per machine with
# DOTFILES_STREAMDECK="false" in machine.env; then the private repo isn't fetched.
let
  src = "${streamdeck-workflow}/com.zaid.claude-agents.sdPlugin";

  # The plugin folder with its one runtime dependency (ws) installed.
  plugin = pkgs.buildNpmPackage {
    pname = "streamdeck-claude-agents";
    version = (lib.importJSON "${src}/package.json").version;
    inherit src;
    npmDepsHash = "sha256-P3Bt3AO1+zus6z6JH1h0n+wzEExlJA2gWgcrHKYpFjs=";
    dontNpmBuild = true;
    installPhase = ''
      runHook preInstall
      cp -r . $out
      runHook postInstall
    '';
  };
in
{
  options.dotfiles.streamdeck.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Install the Claude Agents Stream Deck plugin (WSL only).";
  };

  config = lib.mkIf (config.dotfiles.streamdeck.enable && wsl) {
    # Copied, not linked: Stream Deck can't rely on \\wsl.localhost. Stream Deck only
    # loads a plugin at start, so it's restarted when the copy changed.
    home.activation.streamdeckPlugin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      win=/mnt/c/Windows/System32
      app_data="$(cd /mnt/c && $win/cmd.exe /c 'echo %APPDATA%' 2>/dev/null | tr -d '\r')"
      streamdeck="$([ -n "$app_data" ] && /usr/bin/wslpath -u "$app_data")/Elgato/StreamDeck"
      target="$streamdeck/Plugins/com.zaid.claude-agents.sdPlugin"
      rsync=${lib.getExe pkgs.rsync}

      if [ -z "$app_data" ]; then
        warnEcho "Couldn't find Windows' %APPDATA%, Stream Deck plugin not installed."
      elif [ ! -d "$streamdeck" ]; then
        noteEcho "Stream Deck isn't installed on Windows, its Claude Agents plugin is skipped."
      elif [ -L "$target" ]; then
        # A development link (scripts\dev-link.cmd): copying into it would overwrite the checkout.
        warnEcho "$target is a link to a development checkout, left as it is."
      elif [ -n "$($rsync -rLcn --delete --itemize-changes ${plugin}/ "$target/" 2>/dev/null)" ]; then
        running="$(cd /mnt/c && $win/tasklist.exe /FI 'IMAGENAME eq StreamDeck.exe' /NH 2>/dev/null | grep -c StreamDeck.exe)"
        if [ "${"running:-0"}" -gt 0 ]; then
          run $win/taskkill.exe /IM StreamDeck.exe /F > /dev/null
          run sleep 2
        fi
        run mkdir -p "$target"
        run $rsync -rL --delete --chmod=ugo=rwX ${plugin}/ "$target/"
        if [ "${"running:-0"}" -gt 0 ]; then
          # Start-Process detaches it; started directly it would hold this switch open.
          run $win/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command \
            "Start-Process (Join-Path \$env:ProgramFiles 'Elgato\StreamDeck\StreamDeck.exe')"
        fi
      fi
    '';
  };
}
