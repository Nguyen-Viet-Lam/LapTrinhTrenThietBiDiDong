import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';

const PORT = 8080;
const DIR = path.resolve('build/web');

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.wasm': 'application/wasm',
  '.json': 'application/json',
  '.css': 'text/css',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
};

const server = http.createServer((req, res) => {
  const cleanUrl = req.url.split('?')[0];

  // Kill old service worker aggressively
  if (cleanUrl.includes('flutter_service_worker.js')) {
    res.writeHead(200, {
      'Content-Type': 'text/javascript',
      'Cache-Control': 'no-store, no-cache, must-revalidate, max-age=0',
    });
    res.end('self.addEventListener("install", () => self.skipWaiting()); self.addEventListener("activate", () => self.clients.matchAll({type:"window"}).then(c => c.forEach(x => x.navigate(x.url))));');
    return;
  }

  let file = path.join(DIR, cleanUrl);
  let isHtml = false;
  if (!fs.existsSync(file) || fs.statSync(file).isDirectory()) {
    file = path.join(DIR, 'index.html');
    isHtml = true;
  } else if (file.endsWith('.html')) {
    isHtml = true;
  }

  const ext = path.extname(file);
  const type = MIME[ext] || 'application/octet-stream';

  res.writeHead(200, {
    'Content-Type': type,
    'Access-Control-Allow-Origin': '*',
    'Cache-Control': 'no-store, no-cache, must-revalidate, max-age=0',
    'Pragma': 'no-cache',
    'Expires': '0',
  });

  if (isHtml) {
    let content = fs.readFileSync(file, 'utf8');
    const buster = `
<script>
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then(rs => rs.forEach(r => r.unregister()));
}
if ('caches' in window) {
  caches.keys().then(names => names.forEach(n => caches.delete(n)));
}
</script>
</head>`;
    content = content.replace('</head>', buster);
    res.end(content);
  } else {
    fs.createReadStream(file).pipe(res);
  }
});

server.listen(PORT, () => {
  console.log(`Web server running at http://localhost:${PORT} (Anti-cache active)`);
});
