import puppeteer from 'puppeteer-core';

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 850, deviceScaleFactor: 1 });
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 2000));

  const inside = await page.evaluate(() => {
    const pane = document.querySelector('flt-glass-pane');
    if (!pane || !pane.shadowRoot) return 'no shadowRoot';
    const children = Array.from(pane.shadowRoot.querySelectorAll('*')).map(e => ({
      tag: e.tagName,
      className: e.className,
      rect: e.getBoundingClientRect()
    }));
    return children;
  });
  console.log('Inside shadowRoot:', inside);
  await browser.close();
}

run().catch(console.error);
