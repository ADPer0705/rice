return {
  {
    -- purely cosmetic: collapses the current buffer into a Rule 110 automaton.
    -- zero practical use, entirely morale. hit this when a build finally passes.
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
    keys = {
      -- deliberately not under <leader>f - that prefix is format, and sharing
      -- it would make nvim pause on every <leader>f waiting to disambiguate
      { "<leader>ca", "<cmd>CellularAutomaton make_it_rain<CR>", desc = "Make it rain (fun)" },
    },
  },
  {
    -- masks secret values in .env-style files so they're not visible on
    -- your screen (screenshares, streaming, shoulder surfers)
    "laytan/cloak.nvim",
    event = "BufReadPre",
    opts = {
      enabled = true,
      cloak_character = "*",
      patterns = {
        { file_pattern = { ".env*", "*.env" }, cloak_pattern = "=.+" },
      },
    },
  },
}
