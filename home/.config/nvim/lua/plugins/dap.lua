-- Debugging for every language in the stack:
--   go            -> leoluz/nvim-dap-go      (delve)
--   python        -> jay-babu/mason-nvim-dap (debugpy)
--   c/cpp/rust    -> jay-babu/mason-nvim-dap (codelldb)
-- Loaded at startup (no lazy trigger) so neotest's `strategy = "dap"` and the
-- <leader>otD mapping always have adapters available.
local function map(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text",
    "leoluz/nvim-dap-go",
    { "jay-babu/mason-nvim-dap.nvim", dependencies = { "williamboman/mason.nvim" } },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    -- python (debugpy) + codelldb (rust/c/cpp); go is owned by nvim-dap-go below
    require("mason-nvim-dap").setup({
      ensure_installed = { "python", "codelldb" },
      automatic_installation = true,
      handlers = {},
    })
    require("dap-go").setup()

    -- javascript/typescript via js-debug-adapter (mason-nvim-dap has no
    -- built-in pwa-node configuration, so it is declared explicitly here).
    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = { command = "js-debug-adapter", args = { "${port}" } },
    }
    for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
      dap.configurations[ft] = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
      }
    end

    dapui.setup()
    require("nvim-dap-virtual-text").setup()

    dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui"] = function() dapui.close() end

    -- <leader>D (not <leader>d: that is remapped to delete-without-yank)
    map("<leader>Db", dap.toggle_breakpoint, "Toggle breakpoint")
    map("<leader>DB", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, "Conditional breakpoint")
    map("<leader>Dc", dap.continue, "Continue / start")
    map("<leader>Di", dap.step_into, "Step into")
    map("<leader>Do", dap.step_out, "Step out")
    map("<leader>Dn", dap.step_over, "Step over")
    map("<leader>Dr", dap.repl.toggle, "Toggle REPL")
    map("<leader>Du", dapui.toggle, "Toggle debug UI")
    map("<leader>Dt", dap.terminate, "Terminate session")
    map("<leader>Dl", dap.run_last, "Run last config")
  end,
}
