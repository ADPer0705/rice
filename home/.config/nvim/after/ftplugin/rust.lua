-- All Rust buffer-local keymaps live here, in one namespace: <leader>r.
-- Tests are NOT here: neotest's <leader>ot* keys already work in Rust via the
-- rustaceanvim adapter (see lua/plugins/neotest.lua).
--
-- Rust is space-indented. The global defaults already say this; restating it
-- keeps this file the single source of truth for Rust buffers.
vim.bo.expandtab = true
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.shiftwidth = 4

local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { buffer = true, desc = desc })
end

-- rust-analyzer's grouped code actions. Grouping is a rust-analyzer extension
-- that vim.lsp.buf.code_action cannot render, which is why this differs from
-- the global <leader>vca mapping.
map("<leader>rca", function() vim.cmd.RustLsp("codeAction") end, "Code action (grouped)")
map("<leader>rr", function() vim.cmd.RustLsp("runnables") end, "Run target")
map("<leader>rR", function() vim.cmd.RustLsp({ "runnables", bang = true }) end, "Re-run last target")
map("<leader>rd", function() vim.cmd.RustLsp("debuggables") end, "Debug target")
map("<leader>rD", function() vim.cmd.RustLsp("debug") end, "Debug at cursor")
map("<leader>re", function() vim.cmd.RustLsp("explainError") end, "Explain error")
map("<leader>rm", function() vim.cmd.RustLsp("expandMacro") end, "Expand macro")
map("<leader>rj", function() vim.cmd.RustLsp("joinLines") end, "Join lines")
map("<leader>ro", function() vim.cmd.RustLsp("openCargo") end, "Open Cargo.toml")
map("<leader>rp", function() vim.cmd.RustLsp("parentModule") end, "Go to parent module")

-- Override the global LSP hover with rust-analyzer's hover actions (run, impls,
-- references). Run it twice to enter the actions window.
map("K", function() vim.cmd.RustLsp({ "hover", "actions" }) end, "Hover actions")
