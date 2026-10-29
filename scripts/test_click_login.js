import puppeteer from 'puppeteer-core';
import fs from 'node:fs';
import path from 'node:path';

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 850, deviceScaleFactor: 2 });
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);

  console.log('Clicking login button on desktop...');
  // The login button is at x: 684, y: 510
  await page.mouse.click(684, 510);
  await sleep(3500);

  await page.screenshot({ path: 'docs/screenshots/home_ocean_desktop.png' });
  console.log('Saved home_ocean_desktop.png');

  // Navigate to Admin page by clicking Admin in sidebar
  // In Desktop sidebar, the Admin button is at x: 120, y: 475
  console.log('Clicking Admin link in sidebar...');
  await page.mouse.click(120, 475);
  await sleep(2500);
  await page.screenshot({ path: 'docs/screenshots/admin_ocean_desktop.png' });
  console.log('Saved admin_ocean_desktop.png');

  // Let's also click User Profile in sidebar
  // Index 4: Trang User is at x: 120, y: 430
  console.log('Clicking User Profile link in sidebar...');
  await page.mouse.click(120, 430);
  await sleep(2000);
  await page.screenshot({ path: 'docs/screenshots/profile_ocean_desktop.png' });
  console.log('Saved profile_ocean_desktop.png');

  // Now Mobile Home
  const mobile = await browser.newPage();
  await mobile.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await mobile.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);
  console.log('Clicking login button on mobile...');
  await mobile.mouse.click(206, 660);
  await sleep(3500);
  await mobile.screenshot({ path: 'docs/screenshots/home_ocean_mobile.png' });
  console.log('Saved home_ocean_mobile.png');

  // Open mobile drawer
  console.log('Clicking hamburger menu on mobile (x: 28, y: 45)...');
  await mobile.mouse.click(28, 45);
  await sleep(1500);
  await mobile.screenshot({ path: 'docs/screenshots/mobile_drawer.png' });
  console.log('Saved mobile_drawer.png');

  await browser.close();
}

run().catch(console.error);

