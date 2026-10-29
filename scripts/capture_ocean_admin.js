import puppeteer from 'puppeteer-core';
import fs from 'node:fs';
import path from 'node:path';

const SCREENSHOT_DIR = path.resolve('docs/screenshots');
if (!fs.existsSync(SCREENSHOT_DIR)) {
  fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function run() {
  console.log('Fetching auth token for demo@lifequest.vn...');
  const loginRes = await fetch('http://localhost:3000/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'demo@lifequest.vn', password: '123456' }),
  });
  const data = await loginRes.json();
  const token = data.token;
  console.log('Token acquired:', token ? 'YES' : 'NO');

  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  // 1. Desktop Login (Ocean Blue & White)
  console.log('Capturing Desktop Login...');
  const pageLoginDesktop = await browser.newPage();
  await pageLoginDesktop.setViewport({ width: 1280, height: 800, deviceScaleFactor: 2 });
  await pageLoginDesktop.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2000);
  await pageLoginDesktop.screenshot({ path: path.join(SCREENSHOT_DIR, 'login_ocean_desktop.png') });

  // 2. Mobile Login (Ocean Blue & White)
  console.log('Capturing Mobile Login...');
  const pageLoginMobile = await browser.newPage();
  await pageLoginMobile.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await pageLoginMobile.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2000);
  await pageLoginMobile.screenshot({ path: path.join(SCREENSHOT_DIR, 'login_ocean_mobile.png') });

  // 3. Desktop Home (with Sidebar, Ocean Blue & Light theme)
  console.log('Capturing Desktop Home with Sidebar...');
  const pageHomeDesktop = await browser.newPage();
  await pageHomeDesktop.setViewport({ width: 1280, height: 850, deviceScaleFactor: 2 });
  await pageHomeDesktop.goto('http://localhost:8080', { waitUntil: 'domcontentloaded' });
  await pageHomeDesktop.evaluate((jwt) => {
    localStorage.setItem('flutter.lifequest_jwt_token', jwt);
  }, token);
  await pageHomeDesktop.goto('http://localhost:8080/#/app', { waitUntil: 'networkidle0' });
  await sleep(3500);
  await pageHomeDesktop.screenshot({ path: path.join(SCREENSHOT_DIR, 'home_ocean_desktop.png') });

  // 4. Desktop Admin Screen
  console.log('Capturing Desktop Admin Screen...');
  await pageHomeDesktop.goto('http://localhost:8080/#/admin', { waitUntil: 'networkidle0' });
  await sleep(3000);
  await pageHomeDesktop.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_ocean_desktop.png') });

  // 5. Desktop User Profile Screen
  console.log('Capturing Desktop User Profile Screen...');
  await pageHomeDesktop.goto('http://localhost:8080/#/app', { waitUntil: 'networkidle0' });
  await sleep(1500);
  // Navigate to profile (tab index 4 or via drawer)
  // Let's click Profile button on sidebar
  // Sidebar items are on the left:
  // Logo is at ~ top, Nav links start around y: 220
  // Index 0: Trang chủ (~y: 230)
  // Index 1: Nhiệm vụ (~y: 280)
  // Index 2: AI Plan (~y: 330)
  // Index 3: Nhóm (~y: 380)
  // Index 4: Trang User (~y: 430)
  await pageHomeDesktop.mouse.click(100, 430);
  await sleep(2000);
  await pageHomeDesktop.screenshot({ path: path.join(SCREENSHOT_DIR, 'profile_ocean_desktop.png') });

  // 6. Mobile Home
  console.log('Capturing Mobile Home...');
  const pageHomeMobile = await browser.newPage();
  await pageHomeMobile.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await pageHomeMobile.goto('http://localhost:8080', { waitUntil: 'domcontentloaded' });
  await pageHomeMobile.evaluate((jwt) => {
    localStorage.setItem('flutter.lifequest_jwt_token', jwt);
  }, token);
  await pageHomeMobile.goto('http://localhost:8080/#/app', { waitUntil: 'networkidle0' });
  await sleep(3500);
  await pageHomeMobile.screenshot({ path: path.join(SCREENSHOT_DIR, 'home_ocean_mobile.png') });

  await browser.close();
  console.log('All screenshots captured successfully!');
}

run().catch((err) => {
  console.error('Error during capture:', err);
  process.exit(1);
});

