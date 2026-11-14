-- Harpoon replaces "click through a tree to my 4 active files" with
-- "pin them once, jump with one keystroke." This + Telescope is the
-- combo that's meant to make the sidebar unnecessary.
return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end,
      { desc = "Harpoon: add current file" })
    vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
      { desc = "Harpoon: toggle menu" })

    for i = 1, 4 do
      vim.keymap.set("n", "<leader>" .. i, function() harpoon:list():select(i) end,
        { desc = "Harpoon: go to file " .. i })
    end

    vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end, { desc = "Harpoon: prev" })
    vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end, { desc = "Harpoon: next" })
  end,
}
