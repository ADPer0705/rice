-- Rust-specific extras, the counterpart to gopher.nvim in lua/plugins/go.lua.
--
-- rustaceanvim owns the `rust-analyzer` client. It does NOT go through
-- nvim-lspconfig, so rust_analyzer is deliberately absent from lua/plugins/lsp.lua
-- (both the Mason list and the vim.lsp.enable list) and excluded from
-- mason-lspconfig's automatic_enable. One owner, one client per buffer.
--
-- The binary comes from rustup (`rustup component add rust-analyzer`), not
-- Mason: that ties the server to your toolchain and honours rust-toolchain.toml.
-- Mason's rust-analyzer was uninstalled for the same reason.
return {
  {
    "mrcjkb/rustaceanvim",
    version = "^9", -- requires Neovim >= 0.12
    lazy = false,   -- implements its own filetype-based lazy boot
    -- `init` runs before the plugin loads, which is required for vim.g.rustaceanvim.
    init = function()
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true, -- analyse code behind feature gates
              },
              check = {
                command = "clippy", -- clippy diagnostics through RA; see lint.lua
              },
              procMacro = {
                enable = true, -- without this, macro-heavy crates lose completion
              },
              inlayHints = {
                closureReturnTypeHints = { enable = "with_block" },
                lifetimeElisionHints = { enable = "skip_trivial" },
              },
            },
          },
        },
        -- Auto-detect Mason's codelldb and load launch configs on LspAttach,
        -- so lua/plugins/dap.lua needs no hand-written dap.configurations.rust.
        dap = { autoload_configurations = true },
        -- Tests through neotest (see lua/plugins/neotest.lua) when available.
        tools = { test_executor = "background" },
      }
    end,
  },
}
