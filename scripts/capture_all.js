import puppeteer from 'puppeteer-core';
import fs from 'node:fs';
import path from 'node:path';

const SCREENSHOT_DIR = path.resolve('docs/screenshots');
if (!fs.existsSync(SCREENSHOT_DIR)) {
  fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    defaultViewport: { width: 412, height: 892, deviceScaleFactor: 2 },
  });

  const page = await browser.newPage();
  page.on('console', (msg) => console.log('LOG:', msg.text()));

  console.log('1. Capturing login.png...');
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await page.evaluate(() => localStorage.clear());
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'login.png') });

  console.log('2. Capturing register.png...');
  await page.goto('http://localhost:8080/#/register', { waitUntil: 'networkidle0' });
  await sleep(2000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'register.png') });

  console.log('3. Logging in & capturing home.png...');
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2000);
  // Click login button
  await page.mouse.click(206, 565);
  await sleep(3000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'home.png') });

  console.log('4. Capturing notifications.png...');
  // Click notification bell (top right ~388, 30)
  await page.mouse.click(388, 30);
  await sleep(1500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'notifications.png') });
  // Close sheet by clicking top backdrop
  await page.mouse.click(206, 120);
  await sleep(1000);

  console.log('5. Capturing quests.png...');
  // Tab 2 (Quests) at (123, 850)
  await page.mouse.click(123, 850);
  await sleep(1500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'quests.png') });

  console.log('6. Capturing quest-create.png...');
  // FAB "Quest mới" at bottom right ~ (340, 800)
  await page.mouse.click(340, 800);
  await sleep(1500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'quest-create.png') });
  // Close sheet
  await page.mouse.click(206, 50);
  await sleep(1000);

  console.log('7. Capturing quest-complete.png...');
  // Click on Quest card at (200, 190)
  await page.mouse.click(200, 190);
  await sleep(1500);
  // Complete quest sheet is open
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'quest-complete.png') });
  // Close sheet
  await page.mouse.click(206, 50);
  await sleep(1000);

  console.log('8. Capturing ai-draft.png...');
  // Tab 3 (AI) at (206, 850)
  await page.mouse.click(206, 850);
  await sleep(1500);
  // Click "Tạo kế hoạch an toàn" button around y = 430
  // Since goal textfield has hint "Ví dụ: Ôn thi môn Lập trình thiết bị di động trong 7 ngày"
  // Let's click textfield at (206, 230), type goal
  await page.mouse.click(206, 230);
  await page.keyboard.type('Ôn thi môn Lập trình thiết bị di động trong 7 ngày');
  await sleep(500);
  // Click "Tạo kế hoạch an toàn" at (206, 425)
  await page.mouse.click(206, 425);
  await sleep(4000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'ai-draft.png') });

  console.log('9. Capturing groups.png...');
  // Tab 4 (Groups) at (288, 850)
  await page.mouse.click(288, 850);
  await sleep(1500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'groups.png') });

  console.log('10. Capturing group-detail.png...');
  // Click group card at (200, 120)
  await page.mouse.click(200, 120);
  await sleep(2000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'group-detail.png') });
  // Close sheet
  await page.mouse.click(206, 50);
  await sleep(1000);

  console.log('11. Capturing profile-light.png...');
  // Tab 5 (Profile) at (370, 850)
  await page.mouse.click(370, 850);
  await sleep(1500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'profile-light.png') });

  console.log('12. Capturing safety-center.png...');
  // Scroll down slightly or click "Trung tâm an toàn" around (200, 480)
  await page.mouse.click(200, 480);
  await sleep(1500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'safety-center.png') });
  // Close safety center
  await page.mouse.click(206, 800); // "Đã hiểu" button
  await sleep(1000);

  console.log('13. Capturing profile-dark.png...');
  // Click Dark mode switch around (360, 215)
  await page.mouse.click(360, 215);
  await sleep(1500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'profile-dark.png') });

  await browser.close();
  console.log('Done single screens!');
}

run().catch((err) => {
  console.error('Error during capture:', err);
  process.exit(1);
});

