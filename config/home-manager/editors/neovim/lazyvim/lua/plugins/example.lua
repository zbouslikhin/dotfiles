-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },

  {
    "phaazon/hop.nvim",
    branch = "v2", -- optional but strongly recommended
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
    end,
    keys = {
      { "h", "<cmd>lua require'hop'.hint_words()<CR>", desc = "Hint words" },
      { "l", "<cmd>lua require'hop'.hint_lines()<CR>", desc = "Hint lines" },
      { "h", "<cmd>lua require'hop'.hint_words()<CR>", mode = "v", desc = "Hint words" },
      { "l", "<cmd>lua require'hop'.hint_lines()<CR>", mode = "v", desc = "Hint lines" },
    },
  },

  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },

  {
    "fresh2dev/zellij.vim",
    lazy = false,
    keys = {
      { "<C-h>", "<cmd>ZellijNavigateLeft<CR>", desc = "New Zellij Floating Pane" },
      { "<C-l>", "<cmd>ZellijNavigateRight<CR>", desc = "New Zellij Floating Pane" },
      { "<C-k>", "<cmd>ZellijNavigateUp<CR>", desc = "New Zellij Floating Pane" },
      { "<C-j>", "<cmd>ZellijNavigateDown<CR>", desc = "New Zellij Floating Pane" },
    },
  },
}
