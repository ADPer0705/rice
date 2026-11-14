# Troubleshooting

## Scripts do nothing / `bin/rice: permission denied`

The repo is on NTFS (fuseblk). Exec bits are not reliable. Always invoke:

```bash
bash bin/rice status
bash bootstrap.sh
```

On an ext4 clone the exec bits from git work normally.

## `rice status` says everything drifted

Check the mount type:

```bash
findmnt -T /mnt/s/rice -o FSTYPE,OPTIONS
```

`rice` compares content only (`--no-perms --no-owner --no-group`). If drift
persists, run `bash bin/rice diff` to see the actual text differences.

## auto-cpufreq fails with `ModuleNotFoundError`

A Fedora Python minor upgrade invalidates the venv, because the installer
builds it from `/usr/bin/python3`. Confirm the mismatch:

```bash
cat /opt/auto-cpufreq/current/venv/pyvenv.cfg   # "version" line
python3 --version
```

### Simple case: `auto-cpufreq` still runs

```bash
cd /tmp/auto-cpufreq && git pull --ff-only
sudo ./auto-cpufreq-installer --install
```

The installer builds a new release under `/opt/auto-cpufreq/releases/` and
repoints `current`. The running daemon picks it up on restart.

### Deadlock: installer refuses, CLI is broken

Symptom:

```
Error: The auto-cpufreq daemon is still installed, so the source installation was not changed.
Run 'sudo auto-cpufreq --remove' to remove only the daemon, then run this installer again.
```

...and `sudo auto-cpufreq --remove` fails with `ModuleNotFoundError`. The
installer gates on the marker file `/usr/local/bin/auto-cpufreq-remove`, and
the CLI that would clear it is the thing that is broken. The removal script
itself is standalone bash, so run it directly:

```bash
# 1. Remove the daemon without touching Python
sudo systemctl stop auto-cpufreq 2>/dev/null || true
sudo /usr/local/bin/auto-cpufreq-remove

# 2. Clear the marker and the stale install tree
sudo rm -f /usr/local/bin/auto-cpufreq-remove
sudo rm -rf /opt/auto-cpufreq
sudo systemctl daemon-reload
sudo systemctl reset-failed auto-cpufreq 2>/dev/null || true

# 3. Reinstall
cd /tmp/auto-cpufreq && git pull --ff-only
sudo ./auto-cpufreq-installer --install

# 4. Verify
auto-cpufreq --version
systemctl status auto-cpufreq --no-pager
```

Skipping the `--remove` cleanup helpers (bluetooth auto-enable, TuneD) is safe
when you reinstall immediately: the new daemon re-applies them.

### After any reinstall, refresh the tracked unit

The unit path changed with the release layout:

```
old: /opt/auto-cpufreq/venv/...            (pre-3.x in-place venv)
new: /opt/auto-cpufreq/current/venv/...    (versioned releases)
```

`bash bin/rice system --write` installs whatever is committed, so refresh the
copy first or it will regress the daemon to the old path:

```bash
bash bin/rice system    # dry-run, confirm the only diff is the unit
bash bin/rice sync      # capture /etc/systemd/system/auto-cpufreq.service
```

## The daily timer never runs

```bash
systemctl --user status rice-sync.timer
systemctl --user list-timers rice-sync.timer
journalctl --user -u rice-sync.service -n 50
```

The unit refuses to run when `/mnt/s` is not mounted. If the timer's push
fails, the commit is still created locally; run `git push` manually. Check
`~/.local/state/rice/sync.log` if you add logging.

## `rice sync` refuses to commit

The staged diff matched a secret pattern (`sk-…`, `ghp_…`, private key, …).
Run `git diff --cached` and either remove the secret or add the file to
`.gitignore`. Machine-local shell settings belong in `~/.zshrc.local`.

## Zen config was not copied

Zen creates a random profile directory only after its first launch:

```bash
zen-browser
bash bin/rice deploy
```

`rice` picks the newest `~/.zen/*Default*` directory.

## Fonts look wrong after deploy

```bash
fc-cache -f
fc-list | grep -i jetbrains
```

Ghostty uses `JetBrainsMono NF`; fuzzel/waybar use `JetBrainsMono Nerd Font`.
Both resolve to the same patched family.

## Grub apply refuses to run

`rice system` needs a LUKS UUID. It reads the one already in
`/etc/default/grub`, then falls back to `blkid`. If both fail, pass the UUID
manually by editing `system/etc/default/grub`, or skip the grub step.

## `task` cannot find its data

`home/.taskrc` uses `data.location=~/.task`. If you prefer XDG paths, move the
database and update the line; taskwarrior 3.x supports `~` expansion.

## tmux says `resurrect.tmux` is missing

Bootstrap installs `~/.tmux/plugins/tmux-resurrect` at the pinned commit. Run:

```bash
bash bin/rice install
tmux source-file ~/.tmux.conf
```

`~/.tmux.conf` loads resurrect directly (it does not use TPM), so the plugin
must exist before tmux starts.
