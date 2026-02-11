// Download Minecraft skins using Playwright
// Usage: npx playwright test --config=... OR node with playwright installed

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const DEST = path.join(__dirname, '..', 'textures', 'raw_skins');

const SKINS = [
  {
    url: 'https://www.minecraftskins.com/skin/22878767/luke-skywalker/',
    filename: 'raw_luke_skywalker_new.png',
    name: 'Luke Skywalker',
  },
  {
    url: 'https://www.minecraftskins.com/skin/23718753/anakin-skywalker----clone-wars---star-wars-/',
    filename: 'raw_anakin_skywalker.png',
    name: 'Anakin Skywalker (Clone Wars)',
  },
];

async function downloadSkin(browser, skin) {
  const context = await browser.newContext({
    userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
  });
  const page = await context.newPage();

  console.log(`\n=== Downloading: ${skin.name} ===`);
  console.log(`URL: ${skin.url}`);

  try {
    await page.goto(skin.url, { waitUntil: 'networkidle', timeout: 30000 });

    // Method 1: Find skin image URL in page source
    const content = await page.content();

    // Look for uploads/skins pattern
    const skinUrlMatches = content.match(/https?:\/\/[^"'\s]+uploads\/skins\/[^"'\s]+\.png/g);
    if (skinUrlMatches) {
      console.log(`  Found skin URLs:`, skinUrlMatches);
      // Download the first one (usually the actual skin file)
      const skinUrl = skinUrlMatches[0];
      const response = await page.goto(skinUrl);
      const buffer = await response.body();
      const destPath = path.join(DEST, skin.filename);
      fs.writeFileSync(destPath, buffer);
      console.log(`  SAVED: ${destPath} (${buffer.length} bytes)`);
      await context.close();
      return true;
    }

    // Method 2: Try download button
    console.log('  Trying download button...');
    const downloadPromise = page.waitForEvent('download', { timeout: 10000 }).catch(() => null);
    await page.click('a[href*="download"], .download-button, .btn-download').catch(() => null);
    const download = await downloadPromise;

    if (download) {
      const destPath = path.join(DEST, skin.filename);
      await download.saveAs(destPath);
      console.log(`  SAVED via download: ${destPath}`);
      await context.close();
      return true;
    }

    // Method 3: Find any 64x64 canvas/image
    console.log('  Looking for skin preview images...');
    const imgs = await page.$$eval('img', imgs =>
      imgs.map(i => ({ src: i.src, w: i.naturalWidth, h: i.naturalHeight }))
        .filter(i => i.src && !i.src.includes('data:'))
    );
    console.log(`  All images:`, JSON.stringify(imgs.slice(0, 10), null, 2));

    console.log('  FAILED to download skin');
    await context.close();
    return false;

  } catch (err) {
    console.error(`  Error: ${err.message}`);
    await context.close();
    return false;
  }
}

(async () => {
  const browser = await chromium.launch({ headless: true });

  for (const skin of SKINS) {
    await downloadSkin(browser, skin);
  }

  await browser.close();
  console.log('\nDone!');
})();
