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

  // Device 1: Minh Anh (Owner)
  console.log('1. Setting up Device 1 (Minh Anh - Owner)...');
  const ctx1 = await browser.createBrowserContext();
  const page1 = await ctx1.newPage();
  await page1.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);
  await page1.mouse.click(206, 565); // login demo
  await sleep(2500);
  await page1.mouse.click(288, 850); // Groups tab
  await sleep(1500);
  await page1.mouse.click(200, 120); // Group card
  await sleep(2500);

  // Device 2: Gia Huy (Member)
  console.log('2. Setting up Device 2 (Gia Huy - Member)...');
  const ctx2 = await browser.createBrowserContext();
  const page2 = await ctx2.newPage();
  await page2.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);
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
  await page2.mouse.click(206, 565); // login
  await sleep(2500);
  await page2.mouse.click(288, 850); // Groups tab
  await sleep(1500);
  await page2.mouse.click(200, 120); // Group card
  await sleep(2500);

  // Now both devices are connected to SSE!
  // Let's trigger a step toggle via API to show realtime sync in action
  console.log('3. Triggering realtime sync via API step toggle...');
  const loginRes = await fetch('http://localhost:3000/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'demo@lifequest.vn', password: '123456' }),
  });
  const { token } = await loginRes.json();
  // Toggle step 2 of sample group quest
  await fetch('http://localhost:3000/api/quests/22c7d610-b528-4c66-a62a-4603760ef395/steps/581df6a3-df5d-4628-b2b1-f4f02edf20e9/toggle', {
    method: 'POST',
    headers: { 'Authorization': 'Bearer ' + token },
  });

  // Wait for SSE broadcast and auto-refresh on both pages
  console.log('4. Waiting for SSE event broadcast to both devices...');
  await sleep(2500);

  // Take screenshots of both devices
  const buf1 = await page1.screenshot({ encoding: 'base64' });
  const buf2 = await page2.screenshot({ encoding: 'base64' });

  // Compose side-by-side view into group-realtime.png
  console.log('5. Composing side-by-side screenshot...');
  const compCtx = await browser.createBrowserContext();
  const compPage = await compCtx.newPage();
  await compPage.setViewport({ width: 940, height: 1040, deviceScaleFactor: 2 });

  const html = `
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  * { box-sizing: border-box; }
  body {
    margin: 0;
    padding: 24px;
    background: #0f172a;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    color: #f8fafc;
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  .header {
    text-align: center;
    margin-bottom: 20px;
  }
  .title {
    font-size: 22px;
    font-weight: 700;
    letter-spacing: -0.5px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    color: #ffffff;
  }
  .live-dot {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: #22c55e;
    box-shadow: 0 0 12px #22c55e;
    display: inline-block;
  }
  .subtitle {
    font-size: 13px;
    color: #94a3b8;
    margin-top: 6px;
  }
  .devices {
    display: flex;
    gap: 32px;
    justify-content: center;
  }
  .device-column {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  .device-header {
    margin-bottom: 12px;
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    font-weight: 600;
  }
  .badge {
    padding: 3px 10px;
    border-radius: 9999px;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }
  .badge-owner {
    background: rgba(59, 130, 246, 0.2);
    color: #60a5fa;
    border: 1px solid rgba(59, 130, 246, 0.4);
  }
  .badge-member {
    background: rgba(168, 85, 247, 0.2);
    color: #c084fc;
    border: 1px solid rgba(168, 85, 247, 0.4);
  }
  .phone-frame {
    width: 412px;
    height: 892px;
    border-radius: 36px;
    overflow: hidden;
    background: #000;
    border: 4px solid #334155;
    box-shadow: 0 20px 40px rgba(0,0,0,0.6), 0 0 0 1px rgba(255,255,255,0.1);
  }
  .phone-frame img {
    width: 412px;
    height: 892px;
    display: block;
  }
</style>
</head>
<body>
  <div class="header">
    <div class="title">
      <span class="live-dot"></span>
      LifeQuest Realtime Group Sync (Server-Sent Events)
    </div>
    <div class="subtitle">
      Đồng bộ thời gian thực giữa các thành viên qua SSE (GET /api/groups/:id/events)
    </div>
  </div>
  <div class="devices">
    <div class="device-column">
      <div class="device-header">
        <span>Thiết bị 1: Minh Anh</span>
        <span class="badge badge-owner">Trưởng nhóm</span>
      </div>
      <div class="phone-frame">
        <img src="data:image/png;base64,${buf1}" />
      </div>
    </div>
    <div class="device-column">
      <div class="device-header">
        <span>Thiết bị 2: Gia Huy</span>
        <span class="badge badge-member">Thành viên</span>
      </div>
      <div class="phone-frame">
        <img src="data:image/png;base64,${buf2}" />
      </div>
    </div>
  </div>
</body>
</html>
  `;

  await compPage.setContent(html, { waitUntil: 'networkidle0' });
  await sleep(1000);

  const outputPath = path.resolve('docs/screenshots/group-realtime.png');
  await compPage.screenshot({ path: outputPath });
  console.log('Successfully saved ' + outputPath);

  await browser.close();
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});

