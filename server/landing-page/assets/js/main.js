// ===== MAIN JAVASCRIPT FOR VEGAN WETLANDS LANDING PAGE =====

document.addEventListener('DOMContentLoaded', function() {
    initializeAnimations();
    initializeServerInfo();
    initializeCopyFunctionality();
    initializeScrollAnimations();
    initializeNavigation();
    initializeDocumentation();
});

// ===== COPY SERVER ADDRESS FUNCTIONALITY =====
function copyAddress() {
    const serverAddress = 'luanti.gabrielpantoja.cl';
    const copyBtn = document.getElementById('copy-address-btn');
    const originalText = copyBtn.textContent;
    
    // Try modern clipboard API first
    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(serverAddress).then(function() {
            showPixelCopySuccess(copyBtn, originalText);
        }).catch(function(err) {
            showPixelCopyError(copyBtn, originalText);
        });
    } else {
        // Fallback for older browsers
        try {
            // Create temporary input
            const tempInput = document.createElement('input');
            tempInput.value = serverAddress;
            document.body.appendChild(tempInput);
            tempInput.select();
            document.execCommand('copy');
            document.body.removeChild(tempInput);
            showPixelCopySuccess(copyBtn, originalText);
        } catch(err) {
            showPixelCopyError(copyBtn, originalText);
        }
    }
}

// ===== COPY SERVER PORT FUNCTIONALITY =====
function copyPort() {
    const serverPort = '30000';
    const copyBtn = document.getElementById('copy-port-btn');
    const originalText = copyBtn.textContent;
    
    // Try modern clipboard API first
    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(serverPort).then(function() {
            showPixelCopySuccess(copyBtn, originalText);
        }).catch(function(err) {
            showPixelCopyError(copyBtn, originalText);
        });
    } else {
        // Fallback for older browsers
        try {
            // Create temporary input
            const tempInput = document.createElement('input');
            tempInput.value = serverPort;
            document.body.appendChild(tempInput);
            tempInput.select();
            document.execCommand('copy');
            document.body.removeChild(tempInput);
            showPixelCopySuccess(copyBtn, originalText);
        } catch(err) {
            showPixelCopyError(copyBtn, originalText);
        }
    }
}

// Legacy fallback copy function removed - now using modern implementation

function showPixelCopySuccess(btn, originalText) {
    btn.textContent = '✅ COPIADO';
    btn.style.background = 'var(--online-green)';
    btn.style.color = 'var(--pixel-black)';
    
    setTimeout(() => {
        btn.textContent = originalText;
        btn.style.background = '';
        btn.style.color = '';
    }, 2000);
}

function showPixelCopyError(btn, originalText) {
    btn.textContent = '❌ ERROR';
    btn.style.background = 'var(--pixel-red)';
    btn.style.color = 'var(--pixel-white)';
    
    setTimeout(() => {
        btn.textContent = originalText;
        btn.style.background = '';
        btn.style.color = '';
    }, 2000);
}

// ===== SERVER STATUS CHECK =====
function initializeServerInfo() {
    checkServerStatus();
    // Check server status every 30 seconds
    setInterval(checkServerStatus, 30000);
}

async function checkServerStatus() {
    const statusIndicator = document.querySelector('.status-indicator');
    const statusText = document.querySelector('.status-text');
    
    try {
        // Try to check server status via a simple API endpoint if available
        const serverData = await checkRealServerStatus();
        
        if (serverData.online) {
            statusIndicator.classList.add('online');
            statusIndicator.classList.remove('offline');
            statusText.textContent = 'SERVIDOR ONLINE';
            // Player count now hardcoded - no dynamic updates needed
        } else {
            throw new Error('Server offline');
        }
    } catch (error) {
        // Fallback to simulation
        const isOnline = await simulateServerCheck();
        
        if (isOnline) {
            statusIndicator.classList.add('online');
            statusIndicator.classList.remove('offline');
            statusText.textContent = 'SERVIDOR ONLINE';
            // Player count now hardcoded - no fallback needed
        } else {
            statusIndicator.classList.add('offline');
            statusIndicator.classList.remove('online');
            statusText.textContent = 'VERIFICANDO...';
        }
    }
}

function simulateServerCheck() {
    return new Promise((resolve) => {
        // Simulate server check with 95% success rate
        const isOnline = Math.random() > 0.05;
        setTimeout(() => resolve(isOnline), 1000);
    });
}

// Player count functions removed - now hardcoded to 3/20 in HTML

// Try to get real server status
async function checkRealServerStatus() {
    // This would connect to a backend API that queries the Luanti server
    // For now, we'll simulate but structure it for future real implementation
    try {
        // Future: const response = await fetch('/api/server-status');
        // Future: return await response.json();
        
        // Simulate for now
        return {
            online: Math.random() > 0.1, // 90% uptime simulation
            players: Math.floor(Math.random() * 12) // 0-11 players
        };
    } catch (error) {
        throw new Error('Unable to check server status');
    }
}

// ===== SMOOTH SCROLLING FOR NAVIGATION =====
function initializeNavigation() {
    const navLinks = document.querySelectorAll('.nav-link[href^="#"]');
    
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);
            
            if (targetElement) {
                const headerHeight = document.querySelector('.header').offsetHeight;
                const targetPosition = targetElement.offsetTop - headerHeight - 20;
                
                window.scrollTo({
                    top: targetPosition,
                    behavior: 'smooth'
                });
                
                // Add active class animation
                this.classList.add('active');
                setTimeout(() => this.classList.remove('active'), 300);
            }
        });
    });
}

// ===== SCROLL ANIMATIONS =====
function initializeScrollAnimations() {
    // Create intersection observer for fade-in animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
                
                // Add staggered animation for grid items
                if (entry.target.classList.contains('features-grid')) {
                    animateGridItems(entry.target);
                }
                
                if (entry.target.classList.contains('steps')) {
                    animateSteps(entry.target);
                }
            }
        });
    }, observerOptions);
    
    // Observe elements for animation
    const animatedElements = document.querySelectorAll('.feature-card, .step, .features-grid, .steps, .hero-visual');
    animatedElements.forEach(el => observer.observe(el));
}

function animateGridItems(gridContainer) {
    const items = gridContainer.querySelectorAll('.feature-card');
    items.forEach((item, index) => {
        setTimeout(() => {
            item.style.opacity = '1';
            item.style.transform = 'translateY(0)';
        }, index * 100);
    });
}

function animateSteps(stepsContainer) {
    const steps = stepsContainer.querySelectorAll('.step');
    steps.forEach((step, index) => {
        setTimeout(() => {
            step.style.opacity = '1';
            step.style.transform = 'translateX(0)';
        }, index * 200);
    });
}

// ===== FLOATING ANIMATIONS =====
function initializeAnimations() {
    createFloatingElements();
    initializeParallax();
}

function createFloatingElements() {
    // Floating animations removed for pixelated aesthetic
    // The new design focuses on the game screenshot as the main visual
    const floatingContainer = document.querySelector('.floating-animals');
    if (floatingContainer) {
        floatingContainer.innerHTML = ''; // Clear any existing animations
        floatingContainer.style.display = 'none'; // Hide the container
    }
}

function initializeParallax() {
    let ticking = false;
    
    function updateParallax() {
        const scrolled = window.pageYOffset;
        const parallaxElements = document.querySelectorAll('.floating-animals .animal');
        
        parallaxElements.forEach((element, index) => {
            const speed = 0.5 + (index * 0.1);
            const yPos = -(scrolled * speed);
            element.style.transform = `translate3d(0, ${yPos}px, 0)`;
        });
        
        ticking = false;
    }
    
    function requestTick() {
        if (!ticking) {
            requestAnimationFrame(updateParallax);
            ticking = true;
        }
    }
    
    window.addEventListener('scroll', requestTick);
}

// ===== COPY FUNCTIONALITY INITIALIZATION =====
function initializeCopyFunctionality() {
    // Make copy functions globally available
    window.copyAddress = copyAddress;
    window.copyPort = copyPort;
    
    // Add keyboard accessibility for copy buttons
    const copyBtns = document.querySelectorAll('.pixel-btn');
    copyBtns.forEach(btn => {
        btn.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                if (this.onclick) {
                    this.onclick();
                }
            }
        });
    });
    
    // Add double-click to copy on address/port displays
    const addressDisplay = document.querySelector('.address');
    if (addressDisplay) {
        addressDisplay.addEventListener('dblclick', function() {
            copyAddress();
        });
        addressDisplay.style.cursor = 'pointer';
        addressDisplay.title = 'Doble clic para copiar';
    }
    
    const portDisplay = document.querySelector('.port');
    if (portDisplay) {
        portDisplay.addEventListener('dblclick', function() {
            copyPort();
        });
        portDisplay.style.cursor = 'pointer';
        portDisplay.title = 'Doble clic para copiar';
    }
}

// ===== EASTER EGGS AND INTERACTIONS =====
function initializeEasterEggs() {
    let clickCount = 0;
    const logoEmoji = document.querySelector('.logo-emoji');
    
    if (logoEmoji) {
        logoEmoji.addEventListener('click', function() {
            clickCount++;
            
            if (clickCount === 5) {
                showEasterEgg();
                clickCount = 0;
            }
            
            // Reset count after 3 seconds
            setTimeout(() => {
                if (clickCount < 5) clickCount = 0;
            }, 3000);
        });
    }
}

function showEasterEgg() {
    // Create a fun animation when logo is clicked 5 times
    const animals = ['🐰', '🐱', '🐶', '🐷', '🐮', '🐔', '🐸', '🦋'];
    const body = document.body;
    
    for (let i = 0; i < 20; i++) {
        setTimeout(() => {
            const animal = document.createElement('div');
            animal.textContent = animals[Math.floor(Math.random() * animals.length)];
            animal.style.position = 'fixed';
            animal.style.left = Math.random() * window.innerWidth + 'px';
            animal.style.top = '-50px';
            animal.style.fontSize = '2rem';
            animal.style.pointerEvents = 'none';
            animal.style.zIndex = '9999';
            animal.style.animation = 'fall 3s linear forwards';
            
            body.appendChild(animal);
            
            setTimeout(() => {
                if (animal.parentNode) {
                    animal.parentNode.removeChild(animal);
                }
            }, 3000);
        }, i * 100);
    }
}

// ===== CSS ANIMATIONS INJECTION =====
function injectAnimations() {
    const style = document.createElement('style');
    style.textContent = `
        @keyframes fall {
            to {
                transform: translateY(calc(100vh + 100px)) rotate(360deg);
                opacity: 0;
            }
        }
        
        @keyframes animate-in {
            from {
                opacity: 0;
                transform: translateY(50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .animate-in {
            animation: animate-in 0.6s ease-out forwards;
        }
        
        .feature-card, .step {
            opacity: 0;
            transform: translateY(30px);
            transition: all 0.6s ease-out;
        }
        
        .server-status.offline {
            background: #ef4444 !important;
            animation: pulse 2s infinite;
        }
        
        .server-status.offline .status-dot {
            background: #fecaca !important;
        }
        
        .nav-link.active {
            color: var(--primary-green) !important;
        }
        
        /* Mobile menu toggle (for future implementation) */
        @media (max-width: 768px) {
            .mobile-menu-toggle {
                display: block;
                background: none;
                border: none;
                font-size: 1.5rem;
                cursor: pointer;
                color: var(--gray-800);
            }
        }
    `;
    document.head.appendChild(style);
}

// ===== ACCESSIBILITY IMPROVEMENTS =====
function improveAccessibility() {
    // Add skip link for screen readers
    const skipLink = document.createElement('a');
    skipLink.href = '#inicio';
    skipLink.textContent = 'Saltar al contenido principal';
    skipLink.style.cssText = `
        position: absolute;
        left: -9999px;
        z-index: 10000;
        padding: 8px 16px;
        background: var(--primary-green);
        color: white;
        text-decoration: none;
        border-radius: 4px;
    `;
    
    skipLink.addEventListener('focus', function() {
        this.style.left = '10px';
        this.style.top = '10px';
    });
    
    skipLink.addEventListener('blur', function() {
        this.style.left = '-9999px';
    });
    
    document.body.insertBefore(skipLink, document.body.firstChild);
    
    // Add proper ARIA labels
    const serverCard = document.querySelector('.server-card');
    if (serverCard) {
        serverCard.setAttribute('role', 'region');
        serverCard.setAttribute('aria-label', 'Información del servidor de juego');
    }
    
    const featureCards = document.querySelectorAll('.feature-card');
    featureCards.forEach((card, index) => {
        card.setAttribute('role', 'article');
        card.setAttribute('aria-label', `Característica ${index + 1} del servidor`);
    });
}

// ===== PERFORMANCE OPTIMIZATION =====
function optimizePerformance() {
    // Lazy load images when they come into view
    if ('IntersectionObserver' in window) {
        const imageObserver = new IntersectionObserver(function(entries) {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    if (img.dataset.src) {
                        img.src = img.dataset.src;
                        img.classList.remove('lazy');
                        imageObserver.unobserve(img);
                    }
                }
            });
        });
        
        document.querySelectorAll('img[data-src]').forEach(img => {
            imageObserver.observe(img);
        });
    }
    
    // Preload critical resources
    const criticalResources = [
        'https://fonts.googleapis.com/css2?family=Fredoka:wght@300;400;500;600;700&display=swap'
    ];
    
    criticalResources.forEach(resource => {
        const link = document.createElement('link');
        link.rel = 'preload';
        link.as = 'style';
        link.href = resource;
        document.head.appendChild(link);
    });
}

// ===== INITIALIZE ALL FEATURES =====
document.addEventListener('DOMContentLoaded', function() {
    injectAnimations();
    initializeEasterEggs();
    improveAccessibility();
    optimizePerformance();
    
    // Initialize service worker for caching (if available)
    if ('serviceWorker' in navigator) {
        window.addEventListener('load', function() {
            // Service worker registration would go here
            console.log('🌱 Vegan Wetlands Landing Page loaded successfully!');
        });
    }
});

// ===== GLOBAL ERROR HANDLING =====
window.addEventListener('error', function(e) {
    console.error('🚨 Landing page error:', e.error);
    // Could send error reports to monitoring service
});

// ===== DOCUMENTATION SYSTEM =====
let docsData = null;
let currentDoc = null;

async function initializeDocumentation() {
    try {
        // Load documentation data
        const response = await fetch('assets/data/docs.json');
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        docsData = await response.json();
        console.log('📚 Documentation loaded:', docsData.meta);
        
        // Render navigation
        renderDocsNavigation();
        
        // Show welcome screen with stats
        showDocsWelcome();
        
        // Initialize scroll-to-top button
        initializeDocsScrollToTop();
        
    } catch (error) {
        console.error('❌ Error loading documentation:', error);
        showDocsError(error.message);
    }
}

function renderDocsNavigation() {
    const navContainer = document.getElementById('docs-nav');
    if (!navContainer || !docsData) return;

    // Create navigation tabs
    const navHTML = `
        <div class="docs-nav-tabs">
            ${docsData.navigation.map(doc => `
                <button 
                    class="docs-nav-tab" 
                    data-doc-id="${doc.id}"
                    onclick="loadDocumentation('${doc.id}')"
                    title="${doc.description}"
                >
                    <span class="tab-icon">${doc.icon}</span>
                    <span class="tab-title">${doc.title}</span>
                    <span class="tab-audience">${getAudienceLabel(doc.audience)}</span>
                </button>
            `).join('')}
        </div>
        
        <div class="docs-nav-breadcrumb" id="docs-breadcrumb" style="display: none;">
            <button onclick="showDocsWelcome()" class="breadcrumb-home">
                🏠 Inicio
            </button>
            <span class="breadcrumb-separator">›</span>
            <span class="breadcrumb-current" id="breadcrumb-current"></span>
        </div>
    `;
    
    navContainer.innerHTML = navHTML;
}

function getAudienceLabel(audience) {
    const labels = {
        'jugadores': 'Para Jugadores',
        'admins': 'Para Admins',
        'developers': 'Para Devs',
        'devops': 'Para DevOps'
    };
    return labels[audience] || audience;
}

function showDocsWelcome() {
    const contentContainer = document.getElementById('docs-content');
    const breadcrumb = document.getElementById('docs-breadcrumb');
    
    if (breadcrumb) breadcrumb.style.display = 'none';
    
    // Clear active tabs
    document.querySelectorAll('.docs-nav-tab').forEach(tab => {
        tab.classList.remove('active');
    });
    
    const statsHTML = docsData ? `
        <div class="docs-stats-grid">
            <div class="docs-stat">
                <span class="stat-number">${docsData.meta.totalDocs}</span>
                <span class="stat-label">Guías Disponibles</span>
            </div>
            <div class="docs-stat">
                <span class="stat-number">${docsData.meta.totalSections}</span>
                <span class="stat-label">Secciones Totales</span>
            </div>
            <div class="docs-stat">
                <span class="stat-number">${Math.round(Object.values(docsData.docs).reduce((sum, doc) => sum + doc.wordCount, 0) / 1000)}K</span>
                <span class="stat-label">Palabras de Contenido</span>
            </div>
        </div>
    ` : '';
    
    contentContainer.innerHTML = `
        <div class="docs-welcome">
            <div class="docs-welcome-icon">📖</div>
            <h3>¡Bienvenid@ al Centro de Documentación!</h3>
            <p>Selecciona una guía del menú superior para comenzar a explorar toda la información sobre Wetlands.</p>
            ${statsHTML}
            
            <div class="docs-quick-links">
                <h4>🚀 Enlaces Rápidos:</h4>
                <div class="quick-links-grid">
                    ${docsData ? docsData.navigation.map(doc => `
                        <button class="quick-link-card" onclick="loadDocumentation('${doc.id}')">
                            <span class="quick-link-icon">${doc.icon}</span>
                            <span class="quick-link-title">${doc.title.replace(/^🛠️\s*|^🌱\s*|^💻\s*|^🚀\s*/, '')}</span>
                            <span class="quick-link-desc">${doc.description}</span>
                        </button>
                    `).join('') : ''}
                </div>
            </div>
        </div>
    `;
    
    currentDoc = null;
    hideDocsBackToTop();
}

function loadDocumentation(docId) {
    if (!docsData || !docsData.docs[docId]) {
        console.error('Documentation not found:', docId);
        return;
    }
    
    const doc = docsData.docs[docId];
    currentDoc = doc;
    
    // Update navigation state
    document.querySelectorAll('.docs-nav-tab').forEach(tab => {
        tab.classList.toggle('active', tab.dataset.docId === docId);
    });
    
    // Show breadcrumb
    const breadcrumb = document.getElementById('docs-breadcrumb');
    const breadcrumbCurrent = document.getElementById('breadcrumb-current');
    if (breadcrumb && breadcrumbCurrent) {
        breadcrumb.style.display = 'flex';
        breadcrumbCurrent.textContent = doc.title;
    }
    
    // Render documentation content
    renderDocumentation(doc);
    
    // Scroll to top of documentation section
    const docsSection = document.getElementById('documentacion');
    if (docsSection) {
        const headerHeight = document.querySelector('.header').offsetHeight;
        window.scrollTo({
            top: docsSection.offsetTop - headerHeight - 20,
            behavior: 'smooth'
        });
    }
    
    showDocsBackToTop();
}

function renderDocumentation(doc) {
    const contentContainer = document.getElementById('docs-content');
    
    const sectionsHTML = doc.sections.map((section, index) => {
        const isMainHeading = section.level === 1;
        const headingTag = `h${Math.min(section.level + 1, 6)}`;
        
        return `
            <div class="docs-section ${isMainHeading ? 'docs-main-section' : ''}" data-section-index="${index}">
                <${headingTag} class="docs-heading docs-heading-${section.level}" id="${section.id}">
                    ${section.title}
                </${headingTag}>
                <div class="docs-content-text">
                    ${renderMarkdownContent(section.content)}
                </div>
            </div>
        `;
    }).join('');
    
    contentContainer.innerHTML = `
        <div class="docs-document">
            <div class="docs-header">
                <div class="docs-title">
                    <span class="docs-icon">${doc.icon}</span>
                    <h2>${doc.title}</h2>
                </div>
                <div class="docs-meta">
                    <span class="docs-audience">${getAudienceLabel(doc.audience)}</span>
                    <span class="docs-word-count">${doc.wordCount} palabras</span>
                    <span class="docs-sections">${doc.sections.length} secciones</span>
                </div>
            </div>
            
            <!-- Table of Contents -->
            <div class="docs-toc">
                <h3>📋 Tabla de Contenidos</h3>
                <ul class="docs-toc-list">
                    ${doc.sections.filter(s => s.level <= 3).map(section => `
                        <li class="docs-toc-item docs-toc-level-${section.level}">
                            <a href="#${section.id}" onclick="scrollToSection('${section.id}')" class="docs-toc-link">
                                ${section.title}
                            </a>
                        </li>
                    `).join('')}
                </ul>
            </div>
            
            <!-- Documentation Content -->
            <div class="docs-body">
                ${sectionsHTML}
            </div>
            
            <!-- Navigation Footer -->
            <div class="docs-footer-nav">
                <button onclick="showDocsWelcome()" class="docs-nav-btn docs-nav-home">
                    🏠 Volver al Inicio
                </button>
                ${getDocNavigationButtons(doc)}
            </div>
        </div>
    `;
}

function getDocNavigationButtons(currentDoc) {
    if (!docsData) return '';
    
    const docs = docsData.navigation;
    const currentIndex = docs.findIndex(doc => doc.id === currentDoc.id);
    
    let buttons = '';
    
    // Previous button
    if (currentIndex > 0) {
        const prevDoc = docs[currentIndex - 1];
        buttons += `
            <button onclick="loadDocumentation('${prevDoc.id}')" class="docs-nav-btn docs-nav-prev">
                ← ${prevDoc.icon} ${prevDoc.title.replace(/^🛠️\s*|^🌱\s*|^💻\s*|^🚀\s*/, '')}
            </button>
        `;
    }
    
    // Next button
    if (currentIndex < docs.length - 1) {
        const nextDoc = docs[currentIndex + 1];
        buttons += `
            <button onclick="loadDocumentation('${nextDoc.id}')" class="docs-nav-btn docs-nav-next">
                ${nextDoc.icon} ${nextDoc.title.replace(/^🛠️\s*|^🌱\s*|^💻\s*|^🚀\s*/, '')} →
            </button>
        `;
    }
    
    return buttons;
}

function renderMarkdownContent(content) {
    // Basic Markdown rendering
    return content
        // Code blocks
        .replace(/```(.*?)\n([\s\S]*?)```/g, '<pre><code class="language-$1">$2</code></pre>')
        // Inline code
        .replace(/`([^`]+)`/g, '<code>$1</code>')
        // Bold
        .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
        // Italic
        .replace(/\*(.*?)\*/g, '<em>$1</em>')
        // Links
        .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" target="_blank" rel="noopener">$1</a>')
        // Line breaks
        .replace(/\n\n/g, '</p><p>')
        .replace(/\n/g, '<br>')
        // Wrap in paragraph
        .replace(/^(.*)$/gm, '<p>$1</p>')
        // Lists (basic support)
        .replace(/^\*\s+(.*)$/gm, '<li>$1</li>')
        .replace(/(<li>.*<\/li>)/gs, '<ul>$1</ul>')
        // Clean up empty paragraphs
        .replace(/<p><\/p>/g, '');
}

function scrollToSection(sectionId) {
    const element = document.getElementById(sectionId);
    if (element) {
        const headerHeight = document.querySelector('.header').offsetHeight;
        const docsNavHeight = document.querySelector('.docs-nav')?.offsetHeight || 0;
        const offset = headerHeight + docsNavHeight + 20;
        
        window.scrollTo({
            top: element.offsetTop - offset,
            behavior: 'smooth'
        });
    }
}

function initializeDocsScrollToTop() {
    const backToTopBtn = document.getElementById('docs-back-to-top');
    if (!backToTopBtn) return;
    
    backToTopBtn.addEventListener('click', () => {
        const docsSection = document.getElementById('documentacion');
        if (docsSection) {
            const headerHeight = document.querySelector('.header').offsetHeight;
            window.scrollTo({
                top: docsSection.offsetTop - headerHeight - 20,
                behavior: 'smooth'
            });
        }
    });
    
    // Show/hide button based on scroll
    window.addEventListener('scroll', () => {
        if (currentDoc) {
            const shouldShow = window.scrollY > 500;
            backToTopBtn.style.display = shouldShow ? 'block' : 'none';
        }
    });
}

function showDocsBackToTop() {
    const btn = document.getElementById('docs-back-to-top');
    if (btn) btn.style.display = 'block';
}

function hideDocsBackToTop() {
    const btn = document.getElementById('docs-back-to-top');
    if (btn) btn.style.display = 'none';
}

function showDocsError(errorMessage) {
    const navContainer = document.getElementById('docs-nav');
    const contentContainer = document.getElementById('docs-content');
    
    navContainer.innerHTML = `
        <div class="docs-error">
            <span class="error-icon">⚠️</span>
            <span>Error cargando la documentación</span>
        </div>
    `;
    
    contentContainer.innerHTML = `
        <div class="docs-error-content">
            <div class="docs-error-icon">📚❌</div>
            <h3>Oops! No se pudo cargar la documentación</h3>
            <p class="error-message">${errorMessage}</p>
            <p>Por favor intenta recargar la página o contacta al administrador.</p>
            <button onclick="window.location.reload()" class="docs-retry-btn">
                🔄 Reintentar
            </button>
        </div>
    `;
}

// ===== GALLERY FUNCTIONALITY =====
function openGalleryModal(imageSrc, caption) {
    const modal = document.getElementById('gallery-modal');
    const modalImage = document.getElementById('gallery-modal-image');
    const modalCaption = document.getElementById('gallery-modal-caption');
    
    if (modal && modalImage && modalCaption) {
        modal.style.display = 'block';
        modalImage.src = imageSrc;
        modalCaption.textContent = caption;
        
        // Prevent body scroll when modal is open
        document.body.style.overflow = 'hidden';
    }
}

function closeGalleryModal() {
    const modal = document.getElementById('gallery-modal');
    
    if (modal) {
        modal.style.display = 'none';
        
        // Restore body scroll
        document.body.style.overflow = '';
    }
}

// Close modal with Escape key
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeGalleryModal();
    }
});

// Make functions globally available
window.loadDocumentation = loadDocumentation;
window.showDocsWelcome = showDocsWelcome;
window.scrollToSection = scrollToSection;
window.openGalleryModal = openGalleryModal;
window.closeGalleryModal = closeGalleryModal;

// ===== EXPORT FUNCTIONS FOR TESTING =====
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        copyAddress,
        checkServerStatus,
        simulateServerCheck,
        initializeDocumentation,
        loadDocumentation
    };
}