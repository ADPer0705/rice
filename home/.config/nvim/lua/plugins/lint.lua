-- Project linting, separate from LSP language diagnostics.
-- go -> golangci-lint (staticcheck/gosimple/errcheck/... default set)
-- sh/bash -> shellcheck, python -> ruff
-- gopls's own `staticcheck` is disabled in lsp.lua so the same finding is not
-- reported twice; gopls still contributes its distinct `analyses`.
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile", "InsertLeave" },
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      go = { "golangcilint" },
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      python = { "ruff" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
}
