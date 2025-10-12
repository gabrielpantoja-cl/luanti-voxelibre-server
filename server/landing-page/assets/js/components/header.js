/**
 * Header Component
 * Shared header with navigation for all pages
 */
export function Header(currentRoute = '/') {
    const isGallery = currentRoute === '/galeria';

    return `
    <header class="header">
        <nav class="nav">
            <div class="logo">
                <span class="logo-emoji">🌱</span>
                <span class="logo-text">Wetlands</span>
            </div>
            <div class="nav-links">
                <a href="#/" class="nav-link ${!isGallery ? 'active' : ''}">Inicio</a>
                <a href="#/galeria" class="nav-link ${isGallery ? 'active' : ''}">🖼️ Galería</a>
                <a href="#/como-jugar" class="nav-link">¿Cómo Jugar?</a>
                <a href="#/caracteristicas" class="nav-link">Características</a>
                <a href="#/documentacion" class="nav-link">🌟 Guías</a>
            </div>
            <button class="nav-toggle" id="nav-toggle">
                <span class="hamburger"></span>
            </button>
        </nav>
    </header>

    <!-- Mobile Navigation -->
    <div class="mobile-nav" id="mobile-nav">
        <a href="#/" class="mobile-nav-link ${!isGallery ? 'active' : ''}">Inicio</a>
        <a href="#/galeria" class="mobile-nav-link ${isGallery ? 'active' : ''}">🖼️ Galería</a>
        <a href="#/como-jugar" class="mobile-nav-link">¿Cómo Jugar?</a>
        <a href="#/caracteristicas" class="mobile-nav-link">Características</a>
        <a href="#/documentacion" class="mobile-nav-link">🌟 Guías</a>
    </div>
    `;
}

/**
 * Initialize mobile navigation toggle
 */
export function initMobileNav() {
    const navToggle = document.getElementById('nav-toggle');
    const mobileNav = document.getElementById('mobile-nav');

    if (navToggle && mobileNav) {
        navToggle.addEventListener('click', () => {
            mobileNav.classList.toggle('active');
            navToggle.classList.toggle('active');
        });

        // Close mobile nav when clicking on a link
        const mobileLinks = mobileNav.querySelectorAll('.mobile-nav-link');
        mobileLinks.forEach(link => {
            link.addEventListener('click', () => {
                mobileNav.classList.remove('active');
                navToggle.classList.remove('active');
            });
        });
    }
}
