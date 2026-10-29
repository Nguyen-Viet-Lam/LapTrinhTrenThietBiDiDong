import puppeteer from 'puppeteer-core';
import path from 'node:path';

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  // Desktop view (Split dual card)
  const pageDesktop = await browser.newPage();
  await pageDesktop.setViewport({ width: 1200, height: 800, deviceScaleFactor: 2 });
  await pageDesktop.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2000);
  await pageDesktop.screenshot({ path: path.resolve('docs/screenshots/login_new_desktop.png') });
  console.log('Saved login_new_desktop.png');

  // Mobile view
  const pageMobile = await browser.newPage();
  await pageMobile.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await pageMobile.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2000);
  await pageMobile.screenshot({ path: path.resolve('docs/screenshots/login.png') });
  console.log('Saved login.png (mobile)');

  await browser.close();
}

run().catch(console.error);

