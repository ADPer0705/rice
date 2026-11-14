# Zen Browser

Zen is installed from COPR `sneexy/zen-browser` as `zen-browser`. The profile
lives at `~/.zen/<random>.Default (release)`.

## What is captured

Only a curated subset is versioned under `home/.zen/profile/`:

| File | Why |
| --- | --- |
| `user.js` | non-default UI prefs (compact mode, single toolbar, workspaces) |
| `chrome/zen-themes.css` | generated theme CSS |
| `zen-themes.json` | Zen mods state |
| `containers.json` | container tabs |
| `extension-preferences.json` | extension enablement |

Never captured: cookies, history, logins, sessions, favicons, caches. The
whole profile is ~380 MB and contains credentials.

## Extensions on the reference machine

| Extension | ID |
| --- | --- |
| uBlock Origin | `uBlock0@raymondhill.net` |
| FoxyProxy | `foxyproxy@eric.h.jung` |
| Google Scholar button | `button@scholar.google.com` |
| NotebookLM Tools | `notebooklm-tools@nlmtools.com` |

Reinstall these from addons.mozilla.org after a fresh setup. Zen mods can be
reinstalled from the Zen theme store.

## Fresh machine

```bash
sudo dnf install zen-browser
zen-browser            # launch once so it creates a profile
bash bin/rice deploy   # copies the curated files into that profile
```

`bin/rice` finds the newest `~/.zen/*Default*` directory automatically. If no
profile exists, `deploy` warns and skips Zen rather than creating a profile
that Zen will ignore.
