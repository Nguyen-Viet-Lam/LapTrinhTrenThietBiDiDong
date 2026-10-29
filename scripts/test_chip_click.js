import puppeteer from 'puppeteer-core';
import path from 'node:path';

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 850, deviceScaleFactor: 2 });
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2000);

  console.log('Clicking User (Demo) chip at (820, 600)...');
  await page.mouse.click(820, 600);
  await sleep(1000);
  await page.screenshot({ path: 'docs/screenshots/test_after_chip_click.png' });
  console.log('Saved test_after_chip_click.png');

  console.log('Clicking Đăng nhập at (889, 457)...');
  await page.mouse.click(889, 457);
  await sleep(4000);
  await page.screenshot({ path: 'docs/screenshots/test_after_login_click.png' });
  console.log('Saved test_after_login_click.png');

  await browser.close();
}

run().catch(console.error);
