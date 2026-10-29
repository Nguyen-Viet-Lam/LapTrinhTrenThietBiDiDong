import puppeteer from 'puppeteer-core';
import fs from 'node:fs';
import path from 'node:path';

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    defaultViewport: { width: 412, height: 892, deviceScaleFactor: 2 },
  });

  // Device 1: Minh Anh (Demo user / Owner)
  const ctx1 = await browser.createBrowserContext();
  const page1 = await ctx1.newPage();
  await page1.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);
  // Default is demo@lifequest.vn, click Login
  console.log('Logging in Device 1 (demo)...');
  await page1.mouse.click(206, 565);
  await sleep(2500);

  // Navigate to Groups tab (x: 288, y: 850)
  console.log('Device 1 navigating to Groups...');
  await page1.mouse.click(288, 850);
  await sleep(1500);

  // Click group card at (200, 120)
  console.log('Device 1 opening Group Detail...');
  await page1.mouse.click(200, 120);
  await sleep(2000);

  // Device 2: Gia Huy (Friend user / Member)
  const ctx2 = await browser.createBrowserContext();
  const page2 = await ctx2.newPage();
  await page2.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);

  // On page2, change email to ban@lifequest.vn
  // Email textfield is around y = 430
  console.log('Logging in Device 2 (ban@lifequest.vn)...');
  await page2.mouse.click(206, 430);
  await sleep(300);
  await page2.keyboard.down('Control');
  await page2.keyboard.press('KeyA');
  await page2.keyboard.up('Control');
  await sleep(200);
  await page2.keyboard.press('Backspace');
  await sleep(200);
  await page2.keyboard.type('ban@lifequest.vn');
  await sleep(500);
  // Click Login button at (206, 565)
  await page2.mouse.click(206, 565);
  await sleep(2500);

  // Navigate to Groups tab (x: 288, y: 850)
  console.log('Device 2 navigating to Groups...');
  await page2.mouse.click(288, 850);
  await sleep(1500);

  // Click group card at (200, 120)
  console.log('Device 2 opening Group Detail...');
  await page2.mouse.click(200, 120);
  await sleep(2500);

  await page1.screenshot({ path: 'scripts/dev1.png' });
  await page2.screenshot({ path: 'scripts/dev2.png' });

  console.log('Saved scripts/dev1.png and scripts/dev2.png');
  await browser.close();
}

run().catch(console.error);

