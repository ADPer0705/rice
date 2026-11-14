-- netrw fallback: opens a bare-bones browser at the current file's dir.
-- Not your daily driver (that's Telescope + Harpoon below) but useful for
-- one-off browsing without leaving nvim.
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open netrw at file's dir" })

-- move selected lines up/down, re-indenting as they go
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- keep the cursor centered through half-page jumps and search hops
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- paste over a visual selection without clobbering the unnamed register
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })

-- explicit system-clipboard yank/delete (keeps default register nvim-only)
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "Q", "<nop>") -- disable Ex mode, nobody means to hit this

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Prev quickfix item" })

-- replace every occurrence of the word under the cursor, cursor lands mid-command
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word under cursor (file-wide)" })

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "chmod +x current file" })

-- move up and down through visual line when wrapped lines
vim.keymap.set({"n", "v"}, "j", "gj", { desc = "Move down by visual line" })
vim.keymap.set({"n", "v"}, "k", "gk", { desc = "Move up by visual line" })
