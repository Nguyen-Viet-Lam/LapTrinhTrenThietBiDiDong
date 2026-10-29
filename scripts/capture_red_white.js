import puppeteer from 'puppeteer-core';
import path from 'node:path';

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  // 1. Desktop Login (Red & White Dual-Pane)
  const pageDesktop = await browser.newPage();
  await pageDesktop.setViewport({ width: 1200, height: 820, deviceScaleFactor: 2 });
  await pageDesktop.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2500);
  await pageDesktop.screenshot({ path: path.resolve('docs/screenshots/login_red_white_desktop.png') });
  console.log('Saved login_red_white_desktop.png');

  // 2. Mobile Login (Red & White)
  const pageMobile = await browser.newPage();
  await pageMobile.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await pageMobile.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2500);
  await pageMobile.screenshot({ path: path.resolve('docs/screenshots/login_red_white_mobile.png') });
  await pageMobile.screenshot({ path: path.resolve('docs/screenshots/login.png') });
  console.log('Saved login_red_white_mobile.png and login.png');

  // 3. Forgot Password Screen
  const pageForgot = await browser.newPage();
  await pageForgot.setViewport({ width: 1040, height: 800, deviceScaleFactor: 2 });
  await pageForgot.goto('http://localhost:8080/#/forgot-password', { waitUntil: 'networkidle0' });
  await sleep(2500);
  await pageForgot.screenshot({ path: path.resolve('docs/screenshots/forgot_password.png') });
  console.log('Saved forgot_password.png');

  // 4. Log in and capture bright Home Screen
  const pageHome = await browser.newPage();
  await pageHome.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await pageHome.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2000);
  // Click login
  await pageHome.mouse.click(206, 565);
  await sleep(3000);
  await pageHome.screenshot({ path: path.resolve('docs/screenshots/home_bright.png') });
  await pageHome.screenshot({ path: path.resolve('docs/screenshots/home.png') });
  console.log('Saved home_bright.png and home.png');

  await browser.close();
}

run().catch(console.error);

