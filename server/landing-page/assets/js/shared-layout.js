/**
 * SHARED LAYOUT SYSTEM
 * Carga componentes compartidos (footer, header) dinámicamente
 * Para mantener consistencia entre todas las páginas de la landing
 */

/**
 * Load shared footer from template
 * Usage: Add <div id="footer-placeholder"></div> where you want the footer
 */
async function loadSharedFooter() {
    const placeholder = document.getElementById('footer-placeholder');

    if (!placeholder) {
        console.log('ℹ️ No footer placeholder found - using inline footer');
        return;
    }

    try {
        const response = await fetch('assets/components/footer.html');

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const footerHTML = await response.text();
        placeholder.innerHTML = footerHTML;

        console.log('✅ Shared footer loaded successfully');
    } catch (error) {
        console.error('❌ Error loading shared footer:', error);

        // Fallback to inline footer if fetch fails
        placeholder.innerHTML = `
            <footer class="footer">
                <div class="container">
                    <div class="footer-content">
                        <div class="footer-section">
                            <h4>🌱 Wetlands</h4>
                            <p>Un servidor de Luanti educativo para toda la familia.</p>
                        </div>
                        <div class="footer-section">
                            <h4>📋 Información del Servidor</h4>
                            <ul>
                                <li>Versión: VoxeLibre (MineClone2)</li>
                                <li>Idioma: Español</li>
                                <li>Máximo jugadores: 20</li>
                                <li>Tipo: Creativo, Sin PvP</li>
                            </ul>
                        </div>
                    </div>
                    <div class="footer-bottom">
                        <p>&copy; 2025 Wetlands. Servidor educativo y sin ánimo de lucro.</p>
                        <p>Luanti es software libre y gratuito. Aprende más en <a href="https://www.luanti.org" target="_blank">luanti.org</a></p>
                    </div>
                </div>
            </footer>
        `;

        console.log('⚠️ Loaded fallback footer');
    }
}

/**
 * Initialize shared layout components
 * Call this from DOMContentLoaded event in each page
 */
function initSharedLayout() {
    loadSharedFooter();
}

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initSharedLayout);
} else {
    // DOM already loaded
    initSharedLayout();
}

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        loadSharedFooter,
        initSharedLayout
    };
}
