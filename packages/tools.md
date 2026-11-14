# Non-dnf tooling

These are installed outside dnf. `bin/rice install` handles the automated
ones; the rest are documented so a fresh machine can be rebuilt.

## Automated by `rice install`

| Tool | Method | Notes |
| --- | --- | --- |
| Oh My Zsh | upstream install script | `$ZSH_CUSTOM/plugins` cloned separately |
| zsh plugins | git clone | `fzf-tab`, `zsh-autosuggestions`, `zsh-completions`, `zsh-syntax-highlighting` |
| TPM + tmux-resurrect | git clone | `~/.tmux/plugins/tpm`, `~/.tmux/plugins/tmux-resurrect` |
| Starship | upstream install script | Fedora repos do not package 1.25.x at time of writing |
| uv | upstream install script | used for MinerU and Python CLI tools |
| `uv` tools | `uv tool install` | see below |
| Go tools | `go install` | `gopls`, `goimports` |
| fonts + cursors | copied from `assets/` | JetBrainsMono NF, Catppuccin cursors |

## `uv` tools

```bash
uv tool install mineru==4.0.3
uv tool install semgrep==1.177.0
uv tool install semgrep-mcp==0.9.0
uv tool install sempropos==0.3.0
uv tool install kaggle==2.2.4
uv tool install merklewatch==1.0.0
uv tool install quaerite==0.1.1
uv tool install transformers==5.21.0
```

## Go tools

```bash
go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest
```

## Rust

Rust and `rust-analyzer` come from rustup, not dnf:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup component add rust-analyzer rustfmt clippy
```

## auto-cpufreq

Installed from the upstream git installer. The distro package is not used
because it lags behind and this machine needs the daemon + systemd unit:

```bash
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq && sudo ./auto-cpufreq-installer --install
```

The installer keeps a versioned release tree and points a symlink at the
active one:

```
/opt/auto-cpufreq/releases/<git-sha>/venv   # per-release virtualenv
/opt/auto-cpufreq/current -> releases/<git-sha>
/usr/local/bin/auto-cpufreq                 # wrapper
/etc/systemd/system/auto-cpufreq.service    # tracked in system/systemd/
```

The unit runs `current/venv/bin/auto-cpufreq --daemon`, so upgrading is just
re-running the installer; the old release is left in `releases/` for rollback.
`/usr/local/sbin/auto-cpufreq` is a leftover duplicate from an older layout.

A Fedora Python minor upgrade still invalidates the venv, because it is built
from `/usr/bin/python3`. See `docs/troubleshooting.md` for the repair recipe,
including the case where the installer refuses to run.

### Config

No `/etc/auto-cpufreq.conf` is present; the daemon uses its defaults. The
example in `system/etc/auto-cpufreq.conf.example` shows the shape if you want
governor/turbo overrides per charger/battery.

## Optional / documented only

| Item | Notes |
| --- | --- |
| NVM | sourced by `.zshrc` if `~/.nvm/nvm.sh` exists |
| npm globals | `bobshell`, `omniroute` (not required by this setup) |
| Zen extensions | listed in `docs/zen.md` |
| Grub `stylish` theme | not committed (no license); grub config only |
| KDE theme assets | snapshot in `docs/theming/kde/`, not ported yet |
