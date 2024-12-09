return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
  },
  config = function()
    require("mason").setup({})

    local cmp_lsp = require("cmp_nvim_lsp")
    local capabilities =
      vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities(), cmp_lsp.default_capabilities())
    require("mason-lspconfig").setup({
      ensure_installed = {
        -- Lua
        "lua_ls",

        -- Python
        "ruff",
        "basedpyright",

        -- TypeScript
        "ts_ls",

        -- Docker
        "dockerls",
        "docker_compose_language_service",
      },
      handlers = {
        ["ruff"] = function()
          require("lspconfig").ruff.setup({
            capabilities = capabilities,
            on_attach = function(client, _)
              client.server_capabilities.hoverProvider = false
            end,
          })
        end,
        ["basedpyright"] = function()
          require("lspconfig").basedpyright.setup({
            capabilities = capabilities,
            settings = {
              basedpyright = {
                disableOrganizeImports = true,
                analysis = {
                  ignore = { "*" },
                  useLibraryCodeForTypes = true,
                  typeCheckingMode = "standard",
                  diagnosticMode = "openFilesOnly",
                  autoImportCompletions = true,
                },
              },
            },
          })
        end,
        ["lua_ls"] = function()
          require("lspconfig").lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                diagnostics = {
                  globals = {
                    "vim",
                    "it",
                    "describe",
                    "before_each",
                    "after_each",
                  },
                },
              },
            },
          })
        end,
      },
    })
    require("mason-tool-installer").setup({
      ensure_installed = {
        "debugpy",
      },
    })
  end,
}
