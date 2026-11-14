# MinerU

Installed as a pinned `uv` tool (`mineru==4.0.3`), not from dnf. The wrapper is
`~/.local/bin/mineru`, the venv is managed by `uv`.

## What is captured

| Path | Notes |
| --- | --- |
| `home/mineru.json` | pipeline config; bucket placeholders are intentionally fake |
| `home/.mineru/config.yaml` | local MinerU config |

Not captured: `~/.mineru/models` (3.1 GB), `doclib` (44 MB + SQLite), logs.
Those are downloaded/generated on demand.

## Fresh machine

```bash
bash bin/rice install        # installs uv + mineru==4.0.3
mineru-models-download       # downloads the model set (~3 GB)
bash bin/rice deploy         # copies the config
```

## Notes

- `mineru.json` ships with placeholder bucket credentials (`ak`, `sk`,
  `endpoint`). Replace them locally; do not commit real cloud credentials.
- The config and models are version-sensitive. Keep the pinned version in
  `packages/uv-tools.txt` in sync with the model download.
- `mineru --version` is captured in `packages/versions.txt`.
