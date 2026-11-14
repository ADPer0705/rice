return {
  "nvim-treesitter/nvim-treesitter",
  -- The `main` branch rewrite does not support lazy-loading; it must load at startup.
  lazy = false,
  build = ":TSUpdate",
  dependencies = { "nvim-treesitter/nvim-treesitter-context" },
  config = function()
    -- Still just "which parsers do I want" - the main branch dropped the
    -- highlight/indent/auto_install config keys, so those move to an autocmd below.
    local parsers = {
      "lua", "vim", "vimdoc", "query",
      "python", "rust", "javascript", "typescript", "tsx",
      "bash", "c", "cpp", "java",
      "yaml", "json", "toml", "markdown", "markdown_inline",
      "dockerfile", "sql",
      "go", "gomod", "gowork", "gosum", -- go stack
    }

    require("nvim-treesitter").setup({})

    -- install only what's missing so startup doesn't rebuild every parser
    local installed = require("nvim-treesitter.config").get_installed("parsers")
    local missing = vim.tbl_filter(function(p)
      return not vim.tbl_contains(installed, p)
    end, parsers)
    if #missing > 0 then
      require("nvim-treesitter").install(missing)
    end

    -- main branch no longer turns these on for us
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        if pcall(vim.treesitter.start) then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    require("treesitter-context").setup({
      max_lines = 3, -- sticky "which function/class am I in" line at the top
    })
  end,
}
