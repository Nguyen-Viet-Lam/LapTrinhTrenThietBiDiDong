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

  // 1. ADMIN DESKTOP HOME (Deep Ocean Abyss Glass)
  console.log('1. Capturing Admin Desktop Home...');
  const pageAdmin = await browser.newPage();
  await pageAdmin.setViewport({ width: 1280, height: 850, deviceScaleFactor: 2 });
  await pageAdmin.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);
  // lam@lifequest.vn is already filled by default
  // Click login at (815, 433)
  await pageAdmin.mouse.click(815, 433);
  await sleep(3500);
  await pageAdmin.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_ocean_desktop.png') });
  console.log('Saved admin_ocean_desktop.png');

  // 2. ADMIN PANEL SCREEN (Deep Ocean Abyss Glass)
  console.log('2. Capturing Admin Management Panel...');
  await pageAdmin.mouse.click(100, 525); // "Quản trị Admin" item in sidebar
  await sleep(3000);
  await pageAdmin.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_panel_desktop.png') });
  console.log('Saved admin_panel_desktop.png');

  // 3. ADMIN MOBILE HOME
  console.log('3. Capturing Admin Mobile Home...');
  const pageAdminMobile = await browser.newPage();
  await pageAdminMobile.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await pageAdminMobile.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);
  // Mobile login button is around (206, 565) or let's measure
  // On mobile viewport (412x892), let's click the login button
  await pageAdminMobile.mouse.click(206, 560);
  await sleep(3500);
  await pageAdminMobile.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_ocean_mobile.png') });
  console.log('Saved admin_ocean_mobile.png');

  // 4. USER DESKTOP HOME (Nova Glass Light Ice)
  console.log('4. Capturing User Desktop Home (Nova Glass Light Ice)...');
  const pageUser = await browser.newPage();
  await pageUser.setViewport({ width: 1280, height: 850, deviceScaleFactor: 2 });
  await pageUser.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);

  // Clear email field and type demo@lifequest.vn
  // Email text field is at x: 684, y: 295
  await pageUser.mouse.click(684, 295);
  // Select all and type
  await pageUser.keyboard.down('Control');
  await pageUser.keyboard.press('KeyA');
  await pageUser.keyboard.up('Control');
  await pageUser.keyboard.press('Backspace');
  await pageUser.keyboard.type('demo@lifequest.vn');

  // Click login button
  await pageUser.mouse.click(815, 433);
  await sleep(4000);
  await pageUser.screenshot({ path: path.join(SCREENSHOT_DIR, 'user_novaglass_desktop.png') });
  console.log('Saved user_novaglass_desktop.png');

  // 5. USER MOBILE HOME (Nova Glass Light Ice)
  console.log('5. Capturing User Mobile Home (Nova Glass Light Ice)...');
  const pageUserMobile = await browser.newPage();
  await pageUserMobile.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await pageUserMobile.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);
  // Click email field on mobile ~ (206, 385)
  await pageUserMobile.mouse.click(206, 385);
  await pageUserMobile.keyboard.down('Control');
  await pageUserMobile.keyboard.press('KeyA');
  await pageUserMobile.keyboard.up('Control');
  await pageUserMobile.keyboard.press('Backspace');
  await pageUserMobile.keyboard.type('demo@lifequest.vn');
  await pageUserMobile.mouse.click(206, 560);
  await sleep(4000);
  await pageUserMobile.screenshot({ path: path.join(SCREENSHOT_DIR, 'user_novaglass_mobile.png') });
  console.log('Saved user_novaglass_mobile.png');

  await browser.close();
  console.log('ALL VIEWS CAPTURED SUCCESSFULLY!');
}

run().catch(console.error);
