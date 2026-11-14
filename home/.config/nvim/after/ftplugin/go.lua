-- All Go buffer-local keymaps live here, in one namespace: <leader>o ("gO").
-- Go is tab-indented (gofmt), so opt out of the global expandtab=true.
vim.bo.expandtab = false
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.shiftwidth = 4

local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { buffer = true, desc = desc })
end

-- imports (gopls code action; the single mechanism for organizing imports)
map("<leader>oI", function()
  vim.lsp.buf.code_action({
    apply = true,
    context = { only = { "source.organizeImports" }, diagnostics = {} },
  })
end, "Organize imports (gopls)")

-- generation / refactors (gopher.nvim -> gomodifytags/impl/iferr/gotests)
map("<leader>oga", "<cmd>GoTagAdd json<CR>", "Add json struct tags")
map("<leader>ogr", "<cmd>GoTagRm json<CR>", "Remove json struct tags")
map("<leader>oge", "<cmd>GoIfErr<CR>", "Generate if err != nil")
map("<leader>ogi", "<cmd>GoImpl<CR>", "Generate interface implementation")
map("<leader>ogj", "<cmd>GoJson<CR>", "JSON to Go type")
map("<leader>ogt", "<cmd>GoTestAdd<CR>", "Generate tests for func/type")
map("<leader>ogc", "<cmd>GoCmt<CR>", "Generate doc comment")
map("<leader>ogg", "<cmd>GoGenerate<CR>", "Run go generate")
