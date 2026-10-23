-- Smooth scrolling redraws the screen many times per scroll. On WSL that flickers in
-- Windows Terminal and makes zellij's top bar vanish, so it is off there; macOS keeps it.
return {
  "folke/snacks.nvim",
  opts = {
    scroll = { enabled = vim.env.WSL_DISTRO_NAME == nil },
  },
}
