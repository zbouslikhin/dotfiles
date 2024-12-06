{ config, pkgs, ... }:

{
    programs.vscode = {
        enable = true;
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        mutableExtensionsDir = false;
        extensions = with pkgs.vscode-extensions; [
          rust-lang.rust-analyzer
          yzhang.markdown-all-in-one
          jock.svg
        ];

        userSettings = {
            "editor.fontSize" = 10;
        };
    };
}
