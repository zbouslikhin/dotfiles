return {
    -- phaazon/hop.nvim was deleted; this is its maintained fork.
    "smoka7/hop.nvim",
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
}
