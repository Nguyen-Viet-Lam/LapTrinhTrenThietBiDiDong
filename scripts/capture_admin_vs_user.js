import puppeteer from 'puppeteer-core';
import fs from 'node:fs';
import path from 'node:path';

const SCREENSHOT_DIR = path.resolve('docs/screenshots');
if (!fs.existsSync(SCREENSHOT_DIR)) {
  fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function getToken(email, password) {
  const res = await fetch('http://localhost:3000/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });
  const data = await res.json();
  return data.token;
}

async function run() {
  console.log('1. Getting Tokens...');
  const userToken = await getToken('demo@lifequest.vn', '123456');
  const adminToken = await getToken('lam@lifequest.vn', '123456');
  console.log('User token:', userToken ? 'OK' : 'FAIL');
  console.log('Admin token:', adminToken ? 'OK' : 'FAIL');

  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  // Capture User Home (Nova Glass Light Ice)
  console.log('2. Capturing User Home (Nova Glass Light Ice)...');
  const pageUser = await browser.newPage();
  await pageUser.setViewport({ width: 1280, height: 900, deviceScaleFactor: 2 });
  await pageUser.goto('http://localhost:8080', { waitUntil: 'domcontentloaded' });
  await pageUser.evaluate((jwt) => {
    localStorage.setItem('flutter.lifequest_jwt_token', jwt);
  }, userToken);
  await pageUser.goto('http://localhost:8080/#/app', { waitUntil: 'networkidle0' });
  await sleep(4000);
  await pageUser.screenshot({ path: path.join(SCREENSHOT_DIR, 'user_home_novaglass_desktop.png') });

  // Capture Admin Home (Deep Abyss Ocean Glass)
  console.log('3. Capturing Admin Home (Deep Abyss Ocean Glass)...');
  const pageAdmin = await browser.newPage();
  await pageAdmin.setViewport({ width: 1280, height: 900, deviceScaleFactor: 2 });
  await pageAdmin.goto('http://localhost:8080', { waitUntil: 'domcontentloaded' });
  await pageAdmin.evaluate((jwt) => {
    localStorage.setItem('flutter.lifequest_jwt_token', jwt);
  }, adminToken);
  await pageAdmin.goto('http://localhost:8080/#/app', { waitUntil: 'networkidle0' });
  await sleep(4000);
  await pageAdmin.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_home_oceanglass_desktop.png') });

  // Capture Admin Management Screen
  console.log('4. Capturing Admin Management Screen (Deep Abyss Ocean Glass)...');
  await pageAdmin.goto('http://localhost:8080/#/admin', { waitUntil: 'networkidle0' });
  await sleep(4000);
  await pageAdmin.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_panel_oceanglass_desktop.png') });

  // Capture Mobile User Home
  console.log('5. Capturing User Mobile Home...');
  const pageMobile = await browser.newPage();
  await pageMobile.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await pageMobile.goto('http://localhost:8080', { waitUntil: 'domcontentloaded' });
  await pageMobile.evaluate((jwt) => {
    localStorage.setItem('flutter.lifequest_jwt_token', jwt);
  }, userToken);
  await pageMobile.goto('http://localhost:8080/#/app', { waitUntil: 'networkidle0' });
  await sleep(4000);
  await pageMobile.screenshot({ path: path.join(SCREENSHOT_DIR, 'user_home_novaglass_mobile.png') });

  await browser.close();
  console.log('Done capturing all views!');
}

run().catch((err) => {
  console.error('Error:', err);
  process.exit(1);
});
