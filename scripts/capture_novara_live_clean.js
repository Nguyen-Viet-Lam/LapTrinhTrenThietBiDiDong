import puppeteer from 'puppeteer-core';
import fs from 'node:fs';
import path from 'node:path';

const SCREENSHOT_DIR = path.resolve('docs/screenshots');
const sleep = (ms) => new Promise(r => setTimeout(r, ms));

async function clickAt(page, x, y) {
  await page.mouse.move(x, y);
  await sleep(60);
  await page.mouse.down();
  await sleep(120);
  await page.mouse.up();
  await sleep(300);
}

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  // ==========================================
  // 1. CAPTURE USER (DEMO) NOVARA ALPINE GLASS
  // ==========================================
  console.log('1. Starting User (Demo) Flow...');
  const pageUser = await browser.newPage();
  await pageUser.setViewport({ width: 1280, height: 950, deviceScaleFactor: 2 });
  await pageUser.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2500);

  // Click User (Demo) chip at (827, 571)
  console.log('Clicking User (Demo) chip at (827, 571)...');
  await clickAt(pageUser, 827, 571);
  await sleep(600);

  // Click Login button at (875, 433)
  console.log('Clicking Đăng nhập button at (875, 433)...');
  await clickAt(pageUser, 875, 433);
  await sleep(4000);

  console.log('User page URL:', pageUser.url());
  await pageUser.screenshot({ path: path.join(SCREENSHOT_DIR, 'novara_user_home_top.png') });
  console.log('Saved novara_user_home_top.png');

  // Scroll down to view the 5 Pillar cards and mountaineer / quote
  await pageUser.evaluate(() => {
    window.scrollBy({ top: 460, behavior: 'instant' });
  });
  await sleep(1500);
  await pageUser.screenshot({ path: path.join(SCREENSHOT_DIR, 'novara_user_pillars.png') });
  console.log('Saved novara_user_pillars.png');

  // ==========================================
  // 2. CAPTURE ADMIN (LÃM) DEEP ABYSS OCEAN GLASS
  // ==========================================
  console.log('2. Starting Admin (Lãm) Flow...');
  const pageAdmin = await browser.newPage();
  await pageAdmin.setViewport({ width: 1280, height: 950, deviceScaleFactor: 2 });
  await pageAdmin.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2500);

  // Click Login button directly at (875, 433) because lam@lifequest.vn is default
  console.log('Clicking Admin Đăng nhập button at (875, 433)...');
  await clickAt(pageAdmin, 875, 433);
  await sleep(4000);

  console.log('Admin page URL:', pageAdmin.url());
  await pageAdmin.screenshot({ path: path.join(SCREENSHOT_DIR, 'novara_admin_home_ocean.png') });
  console.log('Saved novara_admin_home_ocean.png');

  // Click Admin tab in sidebar (at x: 120, y: 475)
  console.log('Navigating to Admin Control Center tab...');
  await clickAt(pageAdmin, 120, 475);
  await sleep(2500);
  await pageAdmin.screenshot({ path: path.join(SCREENSHOT_DIR, 'novara_admin_control_ocean.png') });
  console.log('Saved novara_admin_control_ocean.png');

  // ==========================================
  // 3. CAPTURE MOBILE USER VIEW
  // ==========================================
  console.log('3. Starting Mobile User View...');
  const pageMobile = await browser.newPage();
  await pageMobile.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await pageMobile.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2500);

  // On mobile login:
  // Let's measure mobile coordinates or click User Demo chip
  // In mobile view (412x892):
  // "Đăng nhập" button is at x: 206, y: 565
  // Let's click at (206, 565)
  console.log('Clicking mobile login button at (206, 565)...');
  await clickAt(pageMobile, 206, 565);
  await sleep(4000);
  await pageMobile.screenshot({ path: path.join(SCREENSHOT_DIR, 'novara_mobile_home.png') });
  console.log('Saved novara_mobile_home.png');

  await browser.close();
  console.log('SUCCESS! ALL CAPTURES COMPLETE!');
}

run().catch(console.error);
