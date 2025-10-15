-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local is_wsl = vim.fn.has("wsl") == 1
  or os.getenv("WSL_DISTRO_NAME") ~= nil
  or os.getenv("WSL_INTEROP") ~= nil
-- local is_mac = vim.fn.has("macunix") == 1
-- local is_linux = not is_wsl and not is_mac
vim.api.nvim_create_user_command("CheckWSL", function()
  vim.notify(vim.loop.os_uname().version, vim.log.levels.INFO, { title = "WSL Detection" })
end, {})

-- WSL Clipboard support
if is_wsl then
    vim.api.nvim_echo({{"[WSL Clipboard] Loaded", "MoreMsg"}}, false, {})
  -- This is NeoVim's recommended way to solve clipboard sharing if you use WSL
  -- See: https://github.com/neovim/neovim/wiki/FAQ#how-to-use-the-windows-clipboard-from-wsl
  vim.g.clipboard = {
    name = "wsl-clip",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
vim.opt.clipboard:append("unnamedplus")
end
