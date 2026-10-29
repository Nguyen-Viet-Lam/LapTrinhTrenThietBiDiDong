import puppeteer from 'puppeteer-core';
import fs from 'node:fs';

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function run() {
  const loginRes = await fetch('http://localhost:3000/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'demo@lifequest.vn', password: '123456' }),
  });
  const data = await loginRes.json();
  const token = data.token;
  console.log('Got token:', token.substring(0, 15));

  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 850, deviceScaleFactor: 2 });
  await page.goto('http://localhost:8080', { waitUntil: 'domcontentloaded' });
  await page.evaluate((jwt) => {
    localStorage.setItem('flutter.lifequest_jwt_token', jwt);
  }, token);

  console.log('Reloading page with token in storage...');
  await page.reload({ waitUntil: 'networkidle0' });
  await sleep(4000);

  await page.screenshot({ path: 'docs/screenshots/home_ocean_desktop.png' });
  console.log('Screenshot saved, size:', fs.statSync('docs/screenshots/home_ocean_desktop.png').size);

  await browser.close();
}

run().catch(console.error);

