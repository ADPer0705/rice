-- With this many custom leader-mappings, you don't want to be tabbing back
-- to a cheatsheet. Press <leader> and wait a beat - this shows you what's
-- available from wherever your cursor is.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
  },
}
