return {
  'stevearc/conform.nvim',
  opts = {
    formatters_by_ft = {
      css = { "prettier" },
      html = { "prettier" },
      javascript = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      lua = { "stylua" },
      markdown = { "prettier" },
      rust = { "rustfmt" },
      sh = { "shfmt" },
      tex = { "latexindent" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      ["python"] = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
    },
    notify_on_error = true,
  },
}
