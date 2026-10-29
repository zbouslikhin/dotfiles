{
  config,
  pkgs,
  lib,
  wsl,
  hmDir,
  ...
}:

# Unpacked extensions for Brave/Chrome. Browsers only load these by hand (Load unpacked),
# so a switch just puts them at a fixed place to load them from.
let
  extensions = "${hmDir}/apps/chromium/extensions";
in
if wsl then
  {
    # Windows Brave can't rely on \\wsl.localhost (it fails when WSL isn't running), so copy
    # them to %LOCALAPPDATA%\chromium-extensions on every switch.
    home.activation.chromiumExtensions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      local_app_data="$(cd /mnt/c && /mnt/c/Windows/System32/cmd.exe /c 'echo %LOCALAPPDATA%' 2>/dev/null | tr -d '\r')"
      if [ -n "$local_app_data" ]; then
        target="$(/usr/bin/wslpath -u "$local_app_data")/chromium-extensions"
        run mkdir -p "$target"
        run ${lib.getExe pkgs.rsync} -r --delete --chmod=ugo=rwX ${lib.escapeShellArg extensions}/ "$target/"
      else
        warnEcho "Couldn't find Windows' %LOCALAPPDATA%, chromium extensions not copied."
      fi
    '';
  }
else
  {
    # A symlink into the clone, so edits only need a reload in the browser.
    home.file.".local/share/chromium-extensions".source =
      config.lib.file.mkOutOfStoreSymlink extensions;
  }
