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
  {
    url: 'https://www.minecraftskins.com/skin/23336101/baby-yoda/',
    filename: 'raw_baby_yoda.png',
    name: 'Baby Yoda',
  },
];

(async () => {
  const browser = await chromium.launch({ headless: true });

  for (const skin of SKINS) {
    console.log('\n=== ' + skin.name + ' ===');
    const ctx = await browser.newContext({
      userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
    });
    const page = await ctx.newPage();

    try {
      await page.goto(skin.url, { waitUntil: 'networkidle', timeout: 30000 });
      const content = await page.content();

      // Look for the skin PNG in uploads/skins/
      const re = /https?:\/\/[^"'\s]+uploads\/skins\/[^"'\s]+\.png/g;
      const matches = content.match(re);

      if (matches && matches.length > 0) {
        // Deduplicate
        const unique = [...new Set(matches)];
        console.log('  Found skin URLs:', unique);

        const skinUrl = unique[0];
        const resp = await page.goto(skinUrl);
        const buf = await resp.body();
        const dest = path.join(DEST, skin.filename);
        fs.writeFileSync(dest, buf);
        console.log('  SAVED: ' + dest + ' (' + buf.length + ' bytes)');
      } else {
        console.log('  No uploads/skins URL found, searching images...');
        const imgs = await page.$$eval('img', els =>
          els.map(i => ({ src: i.src, w: i.naturalWidth, h: i.naturalHeight }))
        );
        const relevant = imgs.filter(i =>
          i.src && (i.src.includes('upload') || i.src.includes('skin') || i.w === 64)
        );
        console.log('  Candidate images:', JSON.stringify(relevant.slice(0, 5)));
      }
    } catch (e) {
      console.error('  Error: ' + e.message);
    }

    await ctx.close();
  }

  await browser.close();
  console.log('\nDone!');
})();
