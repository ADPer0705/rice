-- Single owner of everything formatting-related: conform, format-on-save, and
-- <leader>f. lsp.lua deliberately defines no format mapping so there is exactly
-- one path. Formatters run in the order listed; `lsp_format = "fallback"` uses
-- the LSP formatter only when no external formatter is configured/available.
return {
  "stevearc/conform.nvim",
  event = { "BufReadPost", "BufNewFile" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      go = { "goimports", "gofumpt" },
      python = { "ruff_organize_imports", "ruff_format" },
      rust = { "rustfmt" },
      c = { "clang_format" },
      cpp = { "clang_format" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      sh = { "shfmt" },
      bash = { "shfmt" },
    },
    format_on_save = {
      timeout_ms = 1000,
      lsp_format = "fallback",
    },
  },
}
