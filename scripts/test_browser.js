import puppeteer from 'puppeteer-core';

async function test() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    defaultViewport: { width: 412, height: 892, deviceScaleFactor: 2 },
  });

  const page = await browser.newPage();
  console.log('Navigating to http://localhost:8080 ...');
  await page.goto('http://localhost:8080', { waitUntil: 'networkidle0', timeout: 30000 });
  console.log('Page loaded:', await page.title());
  await browser.close();
}

test().catch(err => {
  console.error(err);
  process.exit(1);
});

