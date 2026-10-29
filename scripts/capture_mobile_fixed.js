import puppeteer from 'puppeteer-core';
import path from 'node:path';

const sleep = (ms) => new Promise(r => setTimeout(r, ms));

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2000);

  // Click login at (206, 660)
  await page.mouse.move(206, 660);
  await page.mouse.down();
  await sleep(120);
  await page.mouse.up();
  await sleep(3500);

  await page.screenshot({ path: path.join('docs/screenshots', 'novara_mobile_home_fixed.png') });
  console.log('Saved novara_mobile_home_fixed.png');
  await browser.close();
}

run().catch(console.error);
