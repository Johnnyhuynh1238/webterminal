# Claude Code Web Terminal

Self-host Claude Code CLI behind a web link on your VPS.

This sample uses `ttyd`, `tmux`, Nginx path routing, cookie login, per-browser tmux sessions, and an optional smooth HTML viewer backed by `tmux capture-pane`.

This repo is sanitized. It contains no real domain, password, cookie secret, or personal VPS config.

## Security warning

This exposes a shell through a browser. Treat it like SSH.

Use HTTPS, a strong password, localhost-only services, and never commit real `.htpasswd` or cookie secrets.

## Install outline

```bash
sudo apt-get update
sudo apt-get install -y nginx tmux ttyd apache2-utils python3
sudo scripts/install.sh
sudo htpasswd -B -c /etc/nginx/.htpasswd-claude-code claude
sudo nginx -t && sudo systemctl reload nginx
```

Add `nginx/claude-path.conf` to your HTTPS server block and open `https://your-domain.example/claude/`.

## Files

- `bin/claude-web-terminal` — starts Claude Code in a per-browser tmux session
- `services/claude-web-auth` — cookie login backed by `.htpasswd`
- `services/claude-output-viewer-service` — JSON API for `tmux capture-pane`
- `nginx/claude-path.conf` — Nginx path-based routing
- `systemd/*.service` — systemd service templates
- `public/index.html` — reference UI shell for a smooth viewer/input layout
