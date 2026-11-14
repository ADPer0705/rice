-- Order matters here: leader must be set before lazy.nvim loads any plugin
-- specs that reference it in their own keymaps.
vim.g.mapleader = " "

require("adper.set")
require("adper.remap")
require("adper.lazy_init")
