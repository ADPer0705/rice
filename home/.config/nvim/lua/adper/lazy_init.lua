local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "rose-pine" } },
  checker = { enabled = false }, -- don't auto-check for updates on every startup
  -- lazy polls the spec modules every 2s and re-runs Plugin.load() on any
  -- change, which made editing lua/plugins/*.lua feel like a hot reload.
  -- Config changes are applied with :restart (or :Lazy reload on demand).
  change_detection = {
    enabled = false,
    notify = false,
  },
})
