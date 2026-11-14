# Neovim IDE Setup - Quick Reference

## Initial Setup
After opening nvim for the first time, run:
```vim
:Lazy sync
:MasonInstallAll
```

Wait for all plugins and LSP servers to install.

## Key Bindings

### Leader Key
- Leader: `<Space>`

### File Operations
- `<Space>w` - Save file
- `<Space>q` - Quit
- `<Esc>` - Clear search highlighting

### File Navigation (Telescope)
- `<Space>ff` - Find files
- `<Space>fg` - Live grep (search in files)
- `<Space>fb` - Buffer list
- `<Space>fh` - Help tags

### File Explorer
- `<Space>e` - Toggle file tree

### LSP Features
- `gd` - Go to definition
- `gr` - Go to references
- `K` - Show hover documentation
- `<Space>rn` - Rename symbol
- `<Space>ca` - Code action

### Autocompletion
- `<C-Space>` - Trigger completion
- `<Tab>` - Next item / expand snippet
- `<CR>` (Enter) - Confirm selection
- `<C-e>` - Abort completion
- `<C-b>` / `<C-f>` - Scroll docs

### Comments
- `gcc` - Toggle line comment
- `gbc` - Toggle block comment
- Visual mode: `gc` - Toggle comment

### Git (Gitsigns)
Git changes shown in sign column automatically

## Language Support

### C/C++
- LSP: clangd
- Formatter: clang-format

### Python
- LSP: pyright
- Formatter: black

### Rust
- LSP: rust-analyzer
- Formatter: rustfmt
- Extra: rust-tools for enhanced features

### JavaScript/TypeScript
- LSP: ts_ls
- Formatter: prettier

### Web (HTML/CSS)
- LSP: html, cssls
- Formatter: prettier

### Bash
- LSP: bashls

## Installed Plugins

1. **tokyonight.nvim** - Theme
2. **nvim-treesitter** - Syntax highlighting
3. **mason.nvim** - LSP/tool installer
4. **nvim-lspconfig** - LSP configuration
5. **nvim-cmp** - Autocompletion
6. **telescope.nvim** - Fuzzy finder
7. **nvim-tree** - File explorer
8. **gitsigns** - Git integration
9. **lualine** - Status line
10. **nvim-autopairs** - Auto close brackets
11. **Comment.nvim** - Easy commenting
12. **rust-tools** - Rust enhancements
13. **conform.nvim** - Formatting (format on save enabled)
14. **which-key** - Keybinding help

## Tips

- Format on save is enabled by default
- Clipboard integration with system clipboard
- Line numbers and relative numbers enabled
- Tab = 4 spaces
- Mouse support enabled

## Updating
```vim
:Lazy sync
:TSUpdate
:MasonUpdate
```
