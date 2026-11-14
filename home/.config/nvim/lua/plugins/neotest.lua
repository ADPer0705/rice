-- Test runner. neotest-golang v2 expects the nvim-treesitter `main` branch
-- (already the case) and gotestsum as the runner for stable JSON output.
-- dap_go_enabled is flipped on in lua/plugins/dap.lua (debugging phase).
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    { "fredrikaverpil/neotest-golang", version = "*" },
  },
  keys = {
    { "<leader>ott", function() require("neotest").run.run() end, desc = "Test nearest" },
    { "<leader>otf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test file" },
    { "<leader>ots", function() require("neotest").run.run({ suite = true }) end, desc = "Test package/suite" },
    { "<leader>otl", function() require("neotest").run.run_last() end, desc = "Re-run last test" },
    { "<leader>otS", function() require("neotest").run.stop() end, desc = "Stop test run" },
    { "<leader>oto", function() require("neotest").output.open({ enter = true }) end, desc = "Test output" },
    { "<leader>otO", function() require("neotest").output_panel.toggle() end, desc = "Test output panel" },
    { "<leader>otv", function() require("neotest").summary.toggle() end, desc = "Test summary" },
    { "<leader>otD", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test (dap)" },
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-golang")({
          runner = "gotestsum",
          dap_go_enabled = true, -- nvim-dap-go is set up in lua/plugins/dap.lua
        }),
        -- Rust discovery/commands come from rust-analyzer itself. Do NOT also
        -- add rouge8/neotest-rust: it is archived (Aug 2025) and conflicts.
        require("rustaceanvim.neotest"),
      },
    })
  end,
}
