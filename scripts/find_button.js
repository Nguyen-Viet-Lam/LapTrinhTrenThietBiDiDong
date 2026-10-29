import puppeteer from 'puppeteer-core';

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    defaultViewport: { width: 412, height: 892, deviceScaleFactor: 2 },
  });

  const page = await browser.newPage();
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 1500));
  await page.mouse.click(206, 565); // login
  await new Promise(r => setTimeout(r, 2000));

  await page.mouse.click(206, 850); // AI tab
  await new Promise(r => setTimeout(r, 1500));

  const rects = await page.evaluate(() => {
    const list = [];
    const all = Array.from(document.querySelectorAll('*'));
    for (const el of all) {
      if (el.textContent && el.textContent.includes('Tạo kế hoạch an toàn')) {
        const r = el.getBoundingClientRect();
        list.push({ tag: el.tagName, text: el.textContent.slice(0, 30), x: r.x, y: r.y, w: r.width, h: r.height });
      }
    }
    return list;
  });

  console.log('Found:', rects);
  await browser.close();
}

run().catch(console.error);

