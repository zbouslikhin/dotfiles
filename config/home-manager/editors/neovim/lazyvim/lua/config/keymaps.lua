-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local nvGroup = vim.api.nvim_create_augroup("nv", {})
vim.api.nvim_create_autocmd("LspAttach", {
  group = nvGroup,
  callback = function(event)
    local opts = { buffer = event.buf }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)

    vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", opts)
    vim.keymap.set("n", "gs", "<cmd>Telescope grep_string<cr>", opts)
    vim.keymap.set("n", "gD", "<cmd>Telescope diagnostics<cr>", opts)

    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
})
