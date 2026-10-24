{ ... }:

{
  # mise manages language versions (replaces asdf and reads its .tool-versions).
  # Projects pin their own versions; these are the defaults everywhere else.
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    globalConfig.tools = {
      node = "lts";
    };
  };
}
