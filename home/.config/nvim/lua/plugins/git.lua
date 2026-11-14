return {
  -- inline hunk signs in the gutter, live, for whatever changed the file
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
      },
    },
    config = function(_, opts)
      local gitsigns = require("gitsigns")
      gitsigns.setup(opts)

      vim.keymap.set("n", "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gitsigns.next_hunk() end)
        return "<Ignore>"
      end, { expr = true, desc = "Next git hunk" })

      vim.keymap.set("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gitsigns.prev_hunk() end)
        return "<Ignore>"
      end, { expr = true, desc = "Prev git hunk" })

      vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview hunk" })
      vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage hunk (= accept)" })
      vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset hunk (= reject)" })
      vim.keymap.set("n", "<leader>hb", gitsigns.blame_line, { desc = "Blame current line" })
    end,
  },

  -- full review-panel-style diff view against HEAD/any ref - this is your
  -- "show me everything the agent touched before I commit" command
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diff view: working tree vs HEAD" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Diff view: current file history" },
      { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Close diff view" },
    },
  },

  -- git porcelain (:Git status, :Git blame, :Gdiffsplit, staging from a buffer)
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gs", vim.cmd.Git, desc = "Git status (fugitive)" },
    },
  },
}
