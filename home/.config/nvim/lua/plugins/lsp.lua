return {
  {
    "williamboman/mason.nvim",
    config = function() require("mason").setup() end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      -- adjust this list to your stack; :Mason to browse/install more interactively
      ensure_installed = {
        "lua_ls",       -- editing this config
        "pyright",      -- python
        "bashls",       -- bash
        "jsonls",
        "yamlls",
        "clangd",       -- c/cpp
        "ts_ls",        -- javascript/typescript (mason: typescript-language-server)
      },
      -- rust-analyzer is owned by rustup (see lua/plugins/rust.lua), not Mason.
      -- mason-lspconfig auto-enables every installed server, so without this it
      -- would start lspconfig's rust_analyzer client alongside rustaceanvim's.
      automatic_enable = { exclude = { "rust_analyzer" } },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = {
        "lua_ls", "pyright", "bashls", "jsonls", "yamlls", "clangd",
        -- gopls + ts_ls complete the go and js/ts stacks
        "gopls", "ts_ls",
      }

      -- One wildcard default instead of a per-server loop: rustaceanvim starts
      -- its own `rust-analyzer` client without going through nvim-lspconfig, and
      -- this is how it inherits cmp's capabilities (snippet-aware completion).
      vim.lsp.config("*", { capabilities = capabilities })

      vim.lsp.config.lua_ls = {
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      }

      -- gopls is used from ~/go/bin (system install); it is intentionally NOT
      -- in mason-lspconfig's list, so Mason never shadows your copy.
      vim.lsp.config.gopls = {
        settings = {
          gopls = {
            gofumpt = true,        -- keep gopls output consistent with conform's gofumpt
            -- staticcheck lives in golangci-lint (see lua/plugins/lint.lua) so
            -- findings are not duplicated; gopls contributes the analyses below.
            staticcheck = false,
            usePlaceholders = true,
            completeUnimported = true,
            analyses = {
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-node_modules" },
          },
        },
      }

      vim.lsp.enable(servers)

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(event)
          local opts = { buffer = event.buf }

          -- rust-analyzer sends type/parameter hints; show them for Rust only so
          -- gopls does not add its own inlay noise.
          if vim.bo[event.buf].filetype == "rust" then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
          end

          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
          vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
          vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
        end,
      })
    end,
  },
}
