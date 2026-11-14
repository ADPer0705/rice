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

A Fedora Python minor upgrade invalidates the venv in `/opt/auto-cpufreq`.
On the reference machine the venv was built against Python 3.14 and Fedora
then shipped 3.15:

```bash
cat /opt/auto-cpufreq/venv/pyvenv.cfg   # look at the "version" line
python3 --version
```

Re-run the upstream installer to rebuild the venv against the current Python:

```bash
git clone https://github.com/AdnanHodzic/auto-cpufreq.git /tmp/auto-cpufreq
cd /tmp/auto-cpufreq && sudo ./auto-cpufreq-installer --install
sudo systemctl daemon-reload
sudo systemctl restart auto-cpufreq
systemctl status auto-cpufreq
```

The unit is tracked at `system/systemd/auto-cpufreq.service`, so
`bash bin/rice system --write` reinstalls it if needed.

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
