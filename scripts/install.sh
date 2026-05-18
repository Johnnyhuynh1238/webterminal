#!/usr/bin/env bash
set -euo pipefail
if [[ ${EUID} -ne 0 ]]; then echo "Run as root: sudo scripts/install.sh" >&2; exit 1; fi
install -m 755 bin/claude-web-terminal /usr/local/bin/claude-web-terminal
install -m 755 services/claude-web-auth /usr/local/bin/claude-web-auth
install -m 755 services/claude-output-viewer-service /usr/local/bin/claude-output-viewer-service
install -m 644 systemd/claude-code-web-terminal.service /etc/systemd/system/claude-code-web-terminal.service
install -m 644 systemd/claude-code-web-auth.service /etc/systemd/system/claude-code-web-auth.service
install -m 644 systemd/claude-code-output-viewer.service /etc/systemd/system/claude-code-output-viewer.service
install -d /usr/local/share/claude-code-ttyd
install -d /usr/local/share/claude-code-ttyd/icons
# index.html is the live UI — only seed it on a fresh install so re-runs
# never clobber a customized production HTML. Delete the file or pass
# CLAUDE_WEB_FORCE_INDEX=1 to overwrite intentionally.
TARGET_INDEX=/usr/local/share/claude-code-ttyd/index.html
if [[ ! -f "$TARGET_INDEX" || "${CLAUDE_WEB_FORCE_INDEX:-0}" == "1" ]]; then
  install -m 644 public/index.html "$TARGET_INDEX"
  echo "Installed reference index.html -> $TARGET_INDEX"
else
  echo "Kept existing $TARGET_INDEX (set CLAUDE_WEB_FORCE_INDEX=1 to overwrite)"
fi
install -m 644 public/manifest.webmanifest /usr/local/share/claude-code-ttyd/manifest.webmanifest
install -m 644 public/sw.js /usr/local/share/claude-code-ttyd/sw.js
install -m 644 public/icons/icon-192.png /usr/local/share/claude-code-ttyd/icons/icon-192.png
install -m 644 public/icons/icon-512.png /usr/local/share/claude-code-ttyd/icons/icon-512.png
install -m 644 public/icons/icon-maskable-512.png /usr/local/share/claude-code-ttyd/icons/icon-maskable-512.png
if [[ ! -f /etc/claude-code-web-auth.secret ]]; then tr -dc A-Za-z0-9 </dev/urandom | head -c 64 > /etc/claude-code-web-auth.secret; chown root:www-data /etc/claude-code-web-auth.secret; chmod 640 /etc/claude-code-web-auth.secret; fi
systemctl daemon-reload
systemctl enable claude-code-web-terminal claude-code-web-auth claude-code-output-viewer
echo "Create password: sudo htpasswd -B -c /etc/nginx/.htpasswd-claude-code claude"
echo "Then add nginx/claude-path.conf to your HTTPS server block."
