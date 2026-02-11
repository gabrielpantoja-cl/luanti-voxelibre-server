import { chromium } from '@playwright/test';

const BASE = 'https://luanti.gabrielpantoja.cl';
const results = [];

function log(status, test, detail = '') {
  const icon = status === 'PASS' ? 'PASS' : status === 'WARN' ? 'WARN' : 'FAIL';
  results.push({ icon, test, detail });
  console.log(`[${icon}] ${test}${detail ? ' - ' + detail : ''}`);
}

(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext({ viewport: { width: 1280, height: 720 } });
  const page = await context.newPage();

  // Collect console errors and failed requests
  const consoleErrors = [];
  const failedRequests = [];
  page.on('console', msg => { if (msg.type() === 'error') consoleErrors.push(msg.text()); });
  page.on('requestfailed', req => failedRequests.push(`${req.url()} - ${req.failure()?.errorText}`));

  // ========== 1. Page Load ==========
  console.log('\n--- 1. CARGA DE PAGINA ---');
  const startTime = Date.now();
  const response = await page.goto(BASE, { waitUntil: 'networkidle' });
  const loadTime = Date.now() - startTime;

  if (response.status() === 200) log('PASS', 'Pagina carga OK', `Status ${response.status()}`);
  else log('FAIL', 'Pagina carga', `Status ${response.status()}`);

  if (loadTime < 5000) log('PASS', 'Tiempo de carga', `${loadTime}ms`);
  else log('WARN', 'Tiempo de carga lento', `${loadTime}ms`);

  // ========== 2. Content Checks ==========
  console.log('\n--- 2. CONTENIDO ACTUALIZADO ---');
  const html = await page.content();

  // Check old content is GONE
  const oldPhrases = [
    { text: '100% Friendly', name: 'Viejo: 100% Friendly' },
    { text: 'Sin violencia ni daño', name: 'Viejo: Sin violencia ni daño' },
    { text: 'Comandos Mágicos', name: 'Viejo: Comandos Magicos' },
    { text: 'Sin PvP', name: 'Viejo: Sin PvP' },
    { text: 'aventuras sin violencia', name: 'Viejo: meta sin violencia' },
    { text: '/protect [nombre]', name: 'Viejo: /protect [nombre]' },
    { text: 'docs/CONTRIBUTING.md', name: 'Viejo: link CONTRIBUTING en docs/' },
  ];
  for (const { text, name } of oldPhrases) {
    if (html.includes(text)) log('FAIL', name, 'Aun presente en la pagina');
    else log('PASS', name, 'Eliminado correctamente');
  }

  // Check new content IS present
  const newPhrases = [
    { text: 'Entorno Seguro', name: 'Nuevo: Entorno Seguro' },
    { text: 'PvP solo en arenas', name: 'Nuevo: PvP solo en arenas' },
    { text: '/protect_area', name: 'Nuevo: /protect_area' },
    { text: 'Mira quien esta conectado', name: 'Nuevo: Discord simplificado' },
    { text: 'aventuras seguras y creativas', name: 'Nuevo: meta description' },
  ];
  for (const { text, name } of newPhrases) {
    if (html.includes(text)) log('PASS', name, 'Presente');
    else log('FAIL', name, 'NO encontrado en la pagina');
  }

  // ========== 3. Footer: only 4 commands ==========
  console.log('\n--- 3. FOOTER COMANDOS ---');
  const footerCommands = await page.$$eval('footer li code', els => els.map(e => e.textContent));
  log(footerCommands.length === 4 ? 'PASS' : 'FAIL',
    `Footer tiene ${footerCommands.length} comandos (esperado: 4)`,
    footerCommands.join(', '));

  // ========== 4. Links Check ==========
  console.log('\n--- 4. LINKS ---');
  const links = await page.$$eval('a[href]', els =>
    els.map(e => ({ href: e.getAttribute('href'), text: e.textContent.trim().slice(0, 50) }))
  );

  // Check CONTRIBUTING link
  const contribLink = links.find(l => l.href?.includes('CONTRIBUTING'));
  if (contribLink) {
    if (contribLink.href.includes('blob/main/CONTRIBUTING.md') && !contribLink.href.includes('docs/')) {
      log('PASS', 'Link CONTRIBUTING', contribLink.href);
    } else {
      log('FAIL', 'Link CONTRIBUTING apunta mal', contribLink.href);
    }
  } else {
    log('WARN', 'Link CONTRIBUTING no encontrado');
  }

  // Test CONTRIBUTING link actually works (HTTP check)
  if (contribLink) {
    const contribPage = await context.newPage();
    const contribResp = await contribPage.goto(contribLink.href, { waitUntil: 'domcontentloaded', timeout: 10000 }).catch(e => null);
    if (contribResp && contribResp.status() === 200) log('PASS', 'CONTRIBUTING link accesible', `Status ${contribResp.status()}`);
    else log('FAIL', 'CONTRIBUTING link da error', contribResp ? `Status ${contribResp.status()}` : 'No response');
    await contribPage.close();
  }

  // Check Discord link
  const discordLink = links.find(l => l.href?.includes('discord.gg'));
  if (discordLink) log('PASS', 'Link Discord presente', discordLink.href);
  else log('FAIL', 'Link Discord no encontrado');

  // Check external links for broken ones
  const externalLinks = links.filter(l => l.href?.startsWith('http'));
  console.log(`\n  Total links externos: ${externalLinks.length}`);
  for (const link of externalLinks) {
    if (link.href.includes('discord.gg')) continue; // Discord redirects, skip
    try {
      const testPage = await context.newPage();
      const resp = await testPage.goto(link.href, { waitUntil: 'domcontentloaded', timeout: 10000 }).catch(e => null);
      if (resp && resp.status() < 400) log('PASS', `Link: ${link.text.slice(0, 30)}`, `${resp.status()} - ${link.href}`);
      else log('FAIL', `Link roto: ${link.text.slice(0, 30)}`, `${resp?.status() || 'timeout'} - ${link.href}`);
      await testPage.close();
    } catch (e) {
      log('WARN', `Link timeout: ${link.text.slice(0, 30)}`, link.href);
    }
  }

  // ========== 5. Navigation ==========
  console.log('\n--- 5. NAVEGACION ---');
  const navLinks = await page.$$eval('.nav-link', els => els.map(e => ({
    href: e.getAttribute('href'),
    text: e.textContent.trim()
  })));
  console.log(`  Nav links: ${navLinks.map(l => l.text).join(', ')}`);

  // Test anchor links scroll to sections
  for (const nav of navLinks.filter(n => n.href?.startsWith('#'))) {
    const sectionId = nav.href.replace('#', '');
    const exists = await page.$(`#${sectionId}`);
    if (exists) log('PASS', `Seccion #${sectionId} existe`, nav.text);
    else log('FAIL', `Seccion #${sectionId} NO existe`, nav.text);
  }

  // ========== 6. Gallery link ==========
  console.log('\n--- 6. GALERIA ---');
  const galleryLink = links.find(l => l.href === 'galeria.html');
  if (galleryLink) {
    const galleryPage = await context.newPage();
    const galleryResp = await galleryPage.goto(`${BASE}/galeria.html`, { waitUntil: 'networkidle', timeout: 15000 }).catch(e => null);
    if (galleryResp && galleryResp.status() === 200) log('PASS', 'Galeria carga OK');
    else log('FAIL', 'Galeria error', galleryResp?.status());
    await galleryPage.close();
  }

  // ========== 7. Console errors / failed requests ==========
  console.log('\n--- 7. ERRORES ---');
  if (consoleErrors.length === 0) log('PASS', 'Sin errores de consola');
  else {
    log('WARN', `${consoleErrors.length} errores de consola`);
    consoleErrors.forEach(e => console.log(`  >> ${e}`));
  }
  if (failedRequests.length === 0) log('PASS', 'Sin requests fallidos');
  else {
    log('FAIL', `${failedRequests.length} requests fallidos`);
    failedRequests.forEach(r => console.log(`  >> ${r}`));
  }

  // ========== 8. Mobile responsive ==========
  console.log('\n--- 8. RESPONSIVE MOBILE ---');
  await page.setViewportSize({ width: 375, height: 667 });
  await page.waitForTimeout(500);
  const hamburger = await page.$('.nav-toggle');
  if (hamburger) {
    const isVisible = await hamburger.isVisible();
    log(isVisible ? 'PASS' : 'FAIL', 'Hamburger menu visible en mobile');
  } else {
    log('FAIL', 'Hamburger menu no encontrado');
  }

  // ========== SUMMARY ==========
  console.log('\n========== RESUMEN ==========');
  const pass = results.filter(r => r.icon === 'PASS').length;
  const fail = results.filter(r => r.icon === 'FAIL').length;
  const warn = results.filter(r => r.icon === 'WARN').length;
  console.log(`PASS: ${pass} | FAIL: ${fail} | WARN: ${warn} | Total: ${results.length}`);
  if (fail > 0) {
    console.log('\nFALLOS:');
    results.filter(r => r.icon === 'FAIL').forEach(r => console.log(`  [FAIL] ${r.test} - ${r.detail}`));
  }
  if (warn > 0) {
    console.log('\nADVERTENCIAS:');
    results.filter(r => r.icon === 'WARN').forEach(r => console.log(`  [WARN] ${r.test} - ${r.detail}`));
  }

  await browser.close();
})();
