-- Go-specific tooling that isn't LSP-driven: struct tags, if-err, interface
-- stubs, test scaffolding, json->Go. The backing binaries come from Mason
-- (see lua/plugins/tools.lua); the one exception is json2go, which is not in
-- the Mason registry and is installed via `go install` on install/update.
return {
  "olexsmir/gopher.nvim",
  ft = "go",
  build = function()
    if vim.fn.exepath("json2go") == "" then
      vim.system({ "go", "install", "olexsmir.xyz/json2go/cmd/json2go@latest" }):wait()
    end
  end,
  opts = {},
}
