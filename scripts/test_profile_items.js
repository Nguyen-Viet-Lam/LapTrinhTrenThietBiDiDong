import puppeteer from 'puppeteer-core';
import fs from 'node:fs';

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    defaultViewport: { width: 412, height: 892, deviceScaleFactor: 2 },
  });

  const page = await browser.newPage();
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);
  await page.mouse.click(206, 565); // login
  await sleep(2500);

  // Profile tab
  await page.mouse.click(370, 850);
  await sleep(1500);

  // 1. Click Dark mode switch at (340, 340)
  console.log('Toggling dark mode at (340, 340)...');
  await page.mouse.click(340, 340);
  await sleep(2500);
  await page.screenshot({ path: 'docs/screenshots/profile-dark.png' });
  console.log('Saved profile-dark.png');

  // Switch back to light
  await page.mouse.click(340, 340);
  await sleep(1500);

  // 2. Open Safety Center: scroll down and click
  console.log('Scrolling down and opening safety center...');
  await page.mouse.wheel({ deltaY: 200 });
  await sleep(1000);
  // After scrolling 200px, "Trung tâm an toàn" is around y = 515
  await page.mouse.click(200, 515);
  await sleep(2000);
  await page.screenshot({ path: 'docs/screenshots/safety-center.png' });
  console.log('Saved safety-center.png');

  await browser.close();
}

run().catch(console.error);

