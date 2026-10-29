import puppeteer from 'puppeteer-core';

const sleep = (ms) => new Promise(r => setTimeout(r, ms));

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const page = await browser.newPage();
  page.on('console', (msg) => console.log('PAGE LOG:', msg.type(), msg.text()));
  page.on('pageerror', (err) => console.log('PAGE ERROR:', err.message));
  page.on('request', (req) => {
    if (req.url().includes('3000')) console.log('API REQ:', req.method(), req.url());
  });
  page.on('response', (res) => {
    if (res.url().includes('3000')) console.log('API RES:', res.status(), res.url());
  });

  await page.setViewport({ width: 1280, height: 850, deviceScaleFactor: 2 });
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(3000);

  console.log('Dispatching click at (875, 433)...');
  await page.mouse.move(875, 433);
  await page.mouse.down();
  await sleep(100);
  await page.mouse.up();
  await sleep(3000);

  console.log('Current URL:', page.url());
  await browser.close();
}

run().catch(console.error);
