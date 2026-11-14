return {
  {
    "numToStr/Comment.nvim",
    -- gcc to comment a line, gc in visual mode, gcap for a paragraph, etc.
    opts = {},
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
  {
    "kylechui/nvim-surround",
    -- cs"' to change surrounding " to ', ysiw) to wrap a word in (), ds( to delete it
    version = "*",
    event = "VeryLazy",
    opts = {},
  },
}
