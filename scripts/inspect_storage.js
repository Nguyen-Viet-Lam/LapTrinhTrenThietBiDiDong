import puppeteer from 'puppeteer-core';

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    defaultViewport: { width: 412, height: 892, deviceScaleFactor: 2 },
  });

  const page = await browser.newPage();
  page.on('console', msg => console.log('PAGE LOG:', msg.text()));
  await page.goto('http://localhost:8080', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 2000));

  const storage = await page.evaluate(() => {
    return Object.keys(localStorage).map(k => ({ key: k, val: localStorage.getItem(k) }));
  });
  console.log('localStorage keys:', storage);
  await browser.close();
}

run().catch(console.error);

