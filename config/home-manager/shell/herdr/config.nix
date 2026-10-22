{
  config,
  herdr,
  hmDir,
  ...
}:

{
  # Multiplexer for coding agents, used next to zellij; zsh skips zellij inside it.
  home.packages = [
    herdr
  ];

  xdg.configFile = {
    herdr = {
      source = config.lib.file.mkOutOfStoreSymlink "${hmDir}/shell/herdr/herdr";
    };
  };
}
