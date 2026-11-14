-- VSCode-style folding: tree-sitter fold ranges (indent as the fallback),
-- a fold column with carets, and a floating preview of a folded region.
--
-- This is the one plugin allowed to own fold state. Do not add
-- 'foldmethod'/'foldexpr' settings anywhere else: ufo drives folding
-- through 'foldmethod=manual' and would fight a second fold provider.
return {
  "kevinhwang91/nvim-ufo",
  event = "VeryLazy",
  dependencies = { "kevinhwang91/promise-async" },

  -- Fold options have to exist before ufo attaches to the first buffer.
  init = function()
    vim.o.foldcolumn = "auto"    -- fold gutter only appears when folds exist
    vim.o.foldlevel = 99         -- ufo works via 'foldmethod=manual'; a small
    vim.o.foldlevelstart = 99    -- value would re-close folds after edits
    vim.o.foldenable = true      -- everything open, like VSCode's default
    vim.opt.fillchars:append({
      fold = " ",
      foldopen = "",
      foldclose = "",
      foldsep = " ",
      foldinner = " ",
    })
  end,

  opts = {
    -- Reuse the folds.scm queries already installed with nvim-treesitter;
    -- indent only handles buffers that have no parser.
    provider_selector = function()
      return { "treesitter", "indent" }
    end,

    -- Trailing "󰁂 12" instead of a bare ellipsis, so a closed fold still
    -- reports its size. Width/truncation logic is ufo's documented handler.
    fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
      local newVirtText = {}
      local suffix = (" 󰁂 %d"):format(endLnum - lnum)
      local sufWidth = vim.fn.strdisplaywidth(suffix)
      local targetWidth = width - sufWidth
      local curWidth = 0
      for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
          table.insert(newVirtText, chunk)
        else
          chunkText = truncate(chunkText, targetWidth - curWidth)
          table.insert(newVirtText, { chunkText, chunk[2] })
          chunkWidth = vim.fn.strdisplaywidth(chunkText)
          -- truncate() may return less than requested; pad so the suffix lines up
          if curWidth + chunkWidth < targetWidth then
            suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
          end
          break
        end
        curWidth = curWidth + chunkWidth
      end
      table.insert(newVirtText, { suffix, "MoreMsg" })
      return newVirtText
    end,
  },

  config = function(_, opts)
    local ufo = require("ufo")
    ufo.setup(opts)

    -- za / zo / zc / zj / zk / zi stay stock Vim. ufo requires zR and zM to be
    -- remapped: the built-ins change 'foldlevel', and ufo's next fold update
    -- would undo that. zr/zm get the same aliases so they cannot silently
    -- fall back to that behavior.
    vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "Folds: open all" })
    vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "Folds: close all" })
    vim.keymap.set("n", "zr", ufo.openAllFolds, { desc = "Folds: open all (alias)" })
    vim.keymap.set("n", "zm", ufo.closeAllFolds, { desc = "Folds: close all (alias)" })
    vim.keymap.set("n", "zp", ufo.peekFoldedLinesUnderCursor, { desc = "Folds: peek under cursor" })
  end,
}
