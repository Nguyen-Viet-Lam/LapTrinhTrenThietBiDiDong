import puppeteer from 'puppeteer-core';
import fs from 'node:fs';
import path from 'node:path';

const SCREENSHOT_DIR = path.resolve('docs/screenshots');
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  // Create isolated incognito context for Demo User
  const userContext = await browser.createBrowserContext();
  const page = await userContext.newPage();
  await page.setViewport({ width: 1280, height: 850, deviceScaleFactor: 2 });
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);

  console.log('Typing demo@lifequest.vn...');
  // Click Email input field at (684, 295)
  await page.mouse.click(684, 295);
  await sleep(300);
  await page.keyboard.down('Control');
  await page.keyboard.press('KeyA');
  await page.keyboard.up('Control');
  await page.keyboard.press('Backspace');
  await page.keyboard.type('demo@lifequest.vn');
  await sleep(500);

  console.log('Clicking login button...');
  await page.mouse.click(815, 433);
  await sleep(4000);

  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'user_novaglass_desktop.png') });
  console.log('Saved user_novaglass_desktop.png');

  // Now capture Mobile for Demo User
  const pageMobile = await userContext.newPage();
  await pageMobile.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await pageMobile.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);

  // Click email field on mobile (206, 385)
  console.log('Typing demo user on mobile...');
  await pageMobile.mouse.click(206, 385);
  await sleep(300);
  await pageMobile.keyboard.down('Control');
  await pageMobile.keyboard.press('KeyA');
  await pageMobile.keyboard.up('Control');
  await pageMobile.keyboard.press('Backspace');
  await pageMobile.keyboard.type('demo@lifequest.vn');
  await sleep(500);

  console.log('Clicking login on mobile...');
  await pageMobile.mouse.click(206, 560);
  await sleep(4000);

  await pageMobile.screenshot({ path: path.join(SCREENSHOT_DIR, 'user_novaglass_mobile.png') });
  console.log('Saved user_novaglass_mobile.png');

  await browser.close();
}

run().catch(console.error);
