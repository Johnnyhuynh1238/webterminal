const CACHE = 'claude-terminal-shell-v1';
const SHELL = [
  '/claude/',
  '/claude/manifest.webmanifest',
  '/claude/icons/icon-192.png',
  '/claude/icons/icon-512.png',
  '/claude/icons/icon-maskable-512.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE).then((cache) => cache.addAll(SHELL)).catch(() => null)
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;

  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return;

  // Bypass terminal traffic, auth, and capture endpoints — must stay live.
  if (
    req.headers.get('upgrade') === 'websocket' ||
    url.pathname.startsWith('/claude/ws') ||
    url.pathname === '/claude_login' ||
    url.pathname === '/claude_auth_check' ||
    url.pathname === '/claude_capture'
  ) {
    return;
  }

  // Cache-first for static shell assets under /claude/.
  if (
    url.pathname === '/claude/' ||
    url.pathname.startsWith('/claude/icons/') ||
    url.pathname.endsWith('/manifest.webmanifest') ||
    url.pathname.endsWith('/sw.js')
  ) {
    event.respondWith(
      caches.match(req).then((hit) =>
        hit ||
        fetch(req).then((res) => {
          const copy = res.clone();
          caches.open(CACHE).then((cache) => cache.put(req, copy)).catch(() => null);
          return res;
        }).catch(() => caches.match('/claude/'))
      )
    );
  }
});
