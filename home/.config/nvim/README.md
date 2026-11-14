# Neovim — a modern multi-language IDE

A hand-rolled [`lazy.nvim`](https://github.com/folke/lazy.nvim) configuration
(not a distribution). Tuned for **Go, Python, Rust, C/C++, JavaScript/TypeScript
and Bash**, with LSP, format-on-save, debugging and linting wired for each.

Built and verified against **Neovim 0.12.6** and **Go 1.26**.

## Language support

| Language        | LSP                       | Formatter                  | Debugger          | Linter          |
|-----------------|---------------------------|----------------------------|-------------------|-----------------|
| Go              | `gopls` (system)          | `goimports` + `gofumpt`    | `delve`           | `golangci-lint` |
| Python          | `pyright`                 | `ruff` (imports + format)  | `debugpy`         | `ruff`          |
| Rust            | `rust-analyzer` (rustup)  | `rustfmt`                  | `codelldb`        | `clippy` (via RA)|
| C / C++         | `clangd`                  | `clang-format`             | `codelldb`        | —               |
| JS / TS / TSX   | `ts_ls`                   | `prettier`                 | `js-debug-adapter`| —               |
| Bash / sh       | `bashls`                  | `shfmt`                    | —                 | `shellcheck`    |
| Lua / JSON / YAML | `lua_ls` / `jsonls` / `yamlls` | — (LSP fallback)  | —                 | —               |

`gopls` and `goimports` are used from `~/go/bin` (your system install); every
other tool is managed by **Mason**. `json2go` (used by gopher.nvim) is not in the
Mason registry and is installed via `go install` by a plugin `build` hook.
`rust-analyzer` is the other exception: it comes from `rustup`, so it tracks your
toolchain and honours `rust-toolchain.toml`. Mason's copy is deliberately left
out — a mismatched server is a class of bug that is painful to diagnose.

## Requirements

- Neovim **0.12+**
- `git`, `ripgrep`, `fd`, and a Nerd Font
- `tree-sitter` CLI **0.26.1+** and a C compiler (parsers are built locally)
- `go` with `gopls` + `goimports` on `PATH` (`go install golang.org/x/tools/gopls@latest`)
- `rustup` toolchain with the `rust-analyzer`, `rustfmt`, `clippy` and `rust-src`
  components (`rustup component add rust-analyzer rustfmt clippy rust-src`)

## First run / maintenance

```vim
:Lazy sync            " install/update plugins
:MasonToolsInstall    " install formatters, Go tools, linters, debug adapters
:TSUpdate             " (re)build tree-sitter parsers
:checkhealth          " verify everything
```

## Layout

```
init.lua                     " leader + module boots
lua/adper/                   " editor options, remaps, lazy bootstrap
lua/plugins/                 " one file per concern
  colors, lualine, which-key, snacks, harpoon, undotree, trouble
  treesitter                 " parsers + highlighting/indent (main-branch API)
  folding                    " nvim-ufo: tree-sitter folds, fold column, fold peek
  lsp                        " servers, capabilities, gopls settings, LspAttach maps
  formatting                 " conform: format-on-save + <leader>f
  lint                       " nvim-lint: golangci-lint / shellcheck / ruff
  completion, editing, git, autosave, extras
  tools                      " mason-tool-installer: all non-LSP binaries
  go                         " gopher.nvim (tags, if-err, impl, tests, json2go)
  rust                       " rustaceanvim (rust-analyzer client + settings, DAP autoload)
  neotest                    " neotest + neotest-golang + rustaceanvim adapter
  dap                        " nvim-dap + dap-ui + delve/debugpy/codelldb/pwa-node
after/ftplugin/go.lua        " Go tabs + all <leader>o* Go keymaps
after/ftplugin/rust.lua      " Rust indents + all <leader>r* Rust keymaps
```

Design rules kept throughout:

- **One owner per concern.** `<leader>f` and format-on-save live only in
  `formatting.lua`; LSP defines no format mapping. Import organization has a
  single implementation (`<leader>oI`).
- **No duplicate diagnostics.** gopls `staticcheck` is off; `golangci-lint`
  provides it, and gopls contributes its distinct `analyses`.
- **System vs Mason.** `gopls`/`goimports` stay on `~/go/bin`; Mason installs
  the rest.
- **Rust has one client.** `rustaceanvim` owns `rust-analyzer` (it is excluded
  from `mason-lspconfig`'s `automatic_enable` and absent from `vim.lsp.enable`).
  Clippy diagnostics come from rust-analyzer, not `nvim-lint`, so nothing is
  reported twice.
- **No hot reload.** lazy's `change_detection` is off; config edits apply on
  `:restart` (or `:Lazy reload` for specs only). Autosave skips `~/.config/nvim`.

## Keymaps

Leader is `<Space>`.

**Files / navigation**
- `<C-p>` git files · `<leader>pf` files · `<leader>ps` grep · `<leader>pb` buffers
- `<leader>ph` help · `<leader>pd` diagnostics · `<leader>e` explorer · `<leader>pv` netrw
- `<leader>a` harpoon add · `<C-e>` harpoon menu · `<leader>1..4` harpoon jump

**Editing**
- visual `J`/`K` move lines · `<leader>s` replace word file-wide
- `<leader>y`/`<leader>Y` clipboard yank · `<leader>d` delete without yank · `<leader>p` paste (visual)
- `gcc` comment · `ys`/`cs` surround · `<leader>u` undotree · `<leader>zz` zen
- `<C-\>` or `<leader>tf` terminal

**Folding** (tree-sitter ranges, all open on load)
- `za` toggle · `zo`/`zc` open/close one · `zj`/`zk` next/prev fold · `zi` toggle folding itself
- `zR`/`zM` open/close all · `zp` peek inside the fold under the cursor

**Git**
- `<leader>gd` diffview · `<leader>gh` file history · `<leader>gq` close · `<leader>gs` fugitive
- `]c`/`[c` hunks · `<leader>hp`/`hs`/`hr`/`hb` preview/stage/reset/blame · `<leader>gB` open in browser

**LSP** (per buffer)
- `gd` definition · `K` hover · `<leader>vws` workspace symbol · `<leader>vd` diagnostic float
- `[d`/`]d` diagnostics · `<leader>vca` code action · `<leader>vrr` references · `<leader>vrn` rename · `<C-h>` signature help

**Formatting**
- `<leader>f` format buffer · `<leader>oI` organize imports (Go)

**Go** (`<leader>o`)
- `oga`/`ogr` add/remove json tags · `oge` if-err · `ogi` impl · `ogj` JSON→Go
- `ogt` generate tests · `ogc` doc comment · `ogg` go generate

**Rust** (`<leader>r`)
- `rca` grouped code action · `rr` run target · `rR` re-run · `rd` debug target · `rD` debug at cursor
- `re` explain error · `rm` expand macro · `rj` join lines · `ro` Cargo.toml · `rp` parent module
- `K` hover actions (overrides the global hover in Rust buffers only)

**Tests** (`<leader>ot`)
- `ott` nearest · `otf` file · `ots` package · `otl` re-run · `otS` stop
- `oto` output · `otO` output panel · `otv` summary · `otD` debug test (DAP)

**Debug** (`<leader>D`)
- `Db` toggle breakpoint · `DB` conditional · `Dc` continue/start
- `Di`/`Do`/`Dn` step in/out/over · `Dr` REPL · `Du` UI · `Dt` terminate · `Dl` run last

**Trouble**
- `<leader>tt` diagnostics · `<leader>tq` quickfix

## Not included

- JS/TS **linting** (ESLint needs a project config) — add via `nvim-lint` when needed.
- Bash debugging (very niche) and test **coverage** (`nvim-coverage` is optional).
