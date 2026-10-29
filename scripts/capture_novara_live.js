import puppeteer from 'puppeteer-core';
import fs from 'node:fs';
import path from 'node:path';

const SCREENSHOT_DIR = path.resolve('docs/screenshots');
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  // 1. CAPTURE LOGIN SCREEN WITH DEMO 1-TOUCH CHIPS
  console.log('1. Capturing Login with 1-touch Chips...');
  const pageLogin = await browser.newPage();
  await pageLogin.setViewport({ width: 1280, height: 850, deviceScaleFactor: 2 });
  await pageLogin.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2000);
  await pageLogin.screenshot({ path: path.join(SCREENSHOT_DIR, 'novara_login_desktop.png') });
  console.log('Saved novara_login_desktop.png');

  // Find exact coordinate of the "User (Demo)" chip
  // In right column, chips are below the register button (y ~ 540)
  // Let's click "User (Demo)" chip at ~ (860, 545) or scan
  // Or we can fetch token and set in localStorage directly before navigation!
  const loginRes = await fetch('http://localhost:3000/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'demo@lifequest.vn', password: '123456' }),
  });
  const data = await loginRes.json();
  const token = data.token;

  // 2. CAPTURE NOVARA USER HOME DESKTOP
  console.log('2. Capturing Novara User Home Desktop...');
  const pageUser = await browser.newPage();
  await pageUser.setViewport({ width: 1280, height: 950, deviceScaleFactor: 2 });
  await pageUser.goto('http://localhost:8080', { waitUntil: 'domcontentloaded' });
  await pageUser.evaluate((jwt) => {
    localStorage.clear();
    localStorage.setItem('flutter.lifequest_jwt_token', jwt);
  }, token);
  await pageUser.goto('http://localhost:8080/#/app', { waitUntil: 'networkidle0' });
  await sleep(4000);
  await pageUser.screenshot({ path: path.join(SCREENSHOT_DIR, 'novara_user_home_desktop.png') });
  console.log('Saved novara_user_home_desktop.png');

  // 3. CAPTURE NOVARA USER HOME MOBILE
  console.log('3. Capturing Novara User Home Mobile...');
  const pageUserMobile = await browser.newPage();
  await pageUserMobile.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await pageUserMobile.goto('http://localhost:8080', { waitUntil: 'domcontentloaded' });
  await pageUserMobile.evaluate((jwt) => {
    localStorage.clear();
    localStorage.setItem('flutter.lifequest_jwt_token', jwt);
  }, token);
  await pageUserMobile.goto('http://localhost:8080/#/app', { waitUntil: 'networkidle0' });
  await sleep(4000);
  await pageUserMobile.screenshot({ path: path.join(SCREENSHOT_DIR, 'novara_user_home_mobile.png') });
  console.log('Saved novara_user_home_mobile.png');

  // 4. CAPTURE DEEP ABYSS OCEAN ADMIN HOME DESKTOP
  console.log('4. Capturing Admin Ocean Home Desktop...');
  const adminRes = await fetch('http://localhost:3000/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'lam@lifequest.vn', password: '123456' }),
  });
  const adminData = await adminRes.json();
  const adminToken = adminData.token;

  const pageAdmin = await browser.newPage();
  await pageAdmin.setViewport({ width: 1280, height: 950, deviceScaleFactor: 2 });
  await pageAdmin.goto('http://localhost:8080', { waitUntil: 'domcontentloaded' });
  await pageAdmin.evaluate((jwt) => {
    localStorage.clear();
    localStorage.setItem('flutter.lifequest_jwt_token', jwt);
  }, adminToken);
  await pageAdmin.goto('http://localhost:8080/#/app', { waitUntil: 'networkidle0' });
  await sleep(4000);
  await pageAdmin.screenshot({ path: path.join(SCREENSHOT_DIR, 'novara_admin_home_desktop.png') });
  console.log('Saved novara_admin_home_desktop.png');

  await browser.close();
  console.log('ALL LIVE VIEWS CAPTURED!');
}

run().catch(console.error);
