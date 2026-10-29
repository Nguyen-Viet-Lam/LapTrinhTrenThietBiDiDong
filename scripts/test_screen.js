import puppeteer from 'puppeteer-core';
import fs from 'node:fs';

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    defaultViewport: { width: 412, height: 892, deviceScaleFactor: 2 },
  });

  const page = await browser.newPage();
  await page.goto('http://localhost:8080', { waitUntil: 'networkidle0', timeout: 30000 });
  await new Promise(r => setTimeout(r, 3000)); // wait for flutter render

  await page.screenshot({ path: 'scripts/test_screen.png' });
  const stat = fs.statSync('scripts/test_screen.png');
  console.log('Screenshot saved, size:', stat.size);
  await browser.close();
}

run().catch(console.error);

