import puppeteer from 'puppeteer-core';

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const page = await browser.newPage();
  page.on('console', (msg) => console.log('PAGE LOG:', msg.text()));
  page.on('pageerror', (err) => console.log('PAGE ERROR:', err.message));

  await page.setViewport({ width: 1280, height: 800, deviceScaleFactor: 2 });
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await new Promise((r) => setTimeout(r, 2000));

  // Find exact coordinate of the blue button on canvas or DOM
  // Let's use evaluate to find bounding rect of "Đăng nhập" or semantic node
  const sem = await page.evaluate(() => {
    const nodes = Array.from(document.querySelectorAll('flt-semantics, [role="button"], p, span, div'));
    return nodes
      .filter((n) => n.textContent && n.textContent.includes('Đăng nhập'))
      .map((n) => {
        const r = n.getBoundingClientRect();
        return { tag: n.tagName, role: n.getAttribute('role'), aria: n.getAttribute('aria-label'), text: n.textContent.trim(), x: r.x, y: r.y, w: r.width, h: r.height };
      });
  });
  console.log('Semantics / Nodes found:', sem);

  await browser.close();
}

run().catch(console.error);

