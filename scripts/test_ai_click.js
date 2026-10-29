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
  page.on('console', (msg) => console.log('AI PAGE LOG:', msg.text()));

  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);
  await page.mouse.click(206, 565);
  await sleep(2500);

  // Switch to AI tab
  console.log('Clicking AI tab at (206, 850)...');
  await page.mouse.click(206, 850);
  await sleep(1500);

  console.log('Clicking button at (206, 528)...');
  await page.mouse.click(206, 528);
  await sleep(6000);

  await page.screenshot({ path: 'docs/screenshots/ai-draft.png' });
  console.log('Saved ai-draft.png, size:', fs.statSync('docs/screenshots/ai-draft.png').size);

  await browser.close();
}

run().catch(console.error);

