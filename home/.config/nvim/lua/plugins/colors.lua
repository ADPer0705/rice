return {
  "rose-pine/neovim",
  name = "rose-pine",
  priority = 1000, -- load before other UI plugins so there's no flash of default colors
  config = function()
    require("rose-pine").setup({
      styles = { bold = true, italic = true, transparency = false },
    })
    vim.cmd.colorscheme("rose-pine-moon")
  end,
}
