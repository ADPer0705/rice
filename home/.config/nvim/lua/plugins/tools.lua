-- Declarative install of every non-LSP binary the config uses (formatters,
-- Go tooling, linters, debug adapters). Keeping this in one list makes the
-- setup reproducible on a fresh machine; :MasonToolsInstall re-runs it by hand.
-- gopls/goimports are intentionally absent - they come from ~/go/bin.
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "williamboman/mason.nvim" },
  opts = {
    ensure_installed = {
      -- formatters (used by lua/plugins/formatting.lua)
      "gofumpt",
      "prettier",
      "shfmt",
      "clang-format",
      -- go tooling (code generation / analysis)
      "gomodifytags",
      "impl",
      "iferr",
      "gotests",
      "staticcheck",
      "gotestsum", -- neotest-golang runner
      -- linters (used by lua/plugins/lint.lua)
      "golangci-lint",
      "shellcheck",
      -- debug adapters (used by lua/plugins/dap.lua)
      "delve",   -- go
      "debugpy", -- python
      "codelldb", -- rust / c / cpp
      "js-debug-adapter", -- javascript / typescript
    },
    run_on_start = true,
    start_delay = 1000,
  },
}
