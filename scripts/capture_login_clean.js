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

  // Desktop Login
  const pageDesktop = await browser.newPage();
  await pageDesktop.setViewport({ width: 1280, height: 800, deviceScaleFactor: 2 });
  await pageDesktop.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2000);
  await pageDesktop.screenshot({ path: path.join(SCREENSHOT_DIR, 'login_clean_desktop.png') });
  console.log('Saved login_clean_desktop.png');

  // Mobile Login
  const pageMobile = await browser.newPage();
  await pageMobile.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await pageMobile.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2000);
  await pageMobile.screenshot({ path: path.join(SCREENSHOT_DIR, 'login_clean_mobile.png') });
  console.log('Saved login_clean_mobile.png');

  await browser.close();
}

run().catch(console.error);

