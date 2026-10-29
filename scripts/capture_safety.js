import puppeteer from 'puppeteer-core';
import sleep from 'node:timers/promises';

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    defaultViewport: { width: 412, height: 892, deviceScaleFactor: 2 },
  });

  const page = await browser.newPage();
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 1500));
  await page.mouse.click(206, 565); // login
  await new Promise(r => setTimeout(r, 2000));

  await page.mouse.click(370, 850); // profile tab
  await new Promise(r => setTimeout(r, 1500));

  console.log('Clicking Trung tâm an toàn at (200, 715)...');
  await page.mouse.click(200, 715);
  await new Promise(r => setTimeout(r, 2000));

  await page.screenshot({ path: 'docs/screenshots/safety-center.png' });
  console.log('Saved safety-center.png');
  await browser.close();
}

run().catch(console.error);

