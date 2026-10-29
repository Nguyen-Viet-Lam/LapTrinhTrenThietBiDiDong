import puppeteer from 'puppeteer-core';
import fs from 'node:fs';

async function run() {
  // First, get token from backend
  const loginRes = await fetch('http://localhost:3000/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'demo@lifequest.vn', password: '123456' }),
  });
  const data = await loginRes.json();
  const token = data.token;
  console.log('Got token from backend:', token.substring(0, 20) + '...');

  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    defaultViewport: { width: 412, height: 892, deviceScaleFactor: 2 },
  });

  const page = await browser.newPage();
  // Set localStorage before loading app
  await page.goto('http://localhost:8080', { waitUntil: 'domcontentloaded' });
  await page.evaluate((jwt) => {
    localStorage.setItem('flutter.lifequest_jwt_token', jwt);
  }, token);

  // Reload page to let AppController init with token
  await page.reload({ waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 4000));

  await page.screenshot({ path: 'scripts/test_home_logged_in.png' });
  console.log('Saved test_home_logged_in.png, size:', fs.statSync('scripts/test_home_logged_in.png').size);
  await browser.close();
}

run().catch(console.error);

