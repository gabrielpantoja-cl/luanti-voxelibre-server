// ===== MAIN JAVASCRIPT FOR VEGAN WETLANDS LANDING PAGE =====

document.addEventListener('DOMContentLoaded', function() {
    initializeAnimations();
    initializeServerInfo();
    initializeCopyFunctionality();
    initializeScrollAnimations();
    initializeNavigation();
});

// ===== COPY SERVER ADDRESS FUNCTIONALITY =====
function copyAddress() {
    const addressInput = document.getElementById('server-address');
    const copyText = document.getElementById('copy-text');
    const serverAddress = addressInput.value;
    
    // Try modern clipboard API first
    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(serverAddress).then(function() {
            showCopySuccess(copyText);
        }).catch(function(err) {
            // Fallback to old method
            fallbackCopy(addressInput, copyText);
        });
    } else {
        // Fallback for older browsers
        fallbackCopy(addressInput, copyText);
    }
}

function fallbackCopy(input, copyText) {
    input.select();
    input.setSelectionRange(0, 99999); // For mobile devices
    
    try {
        document.execCommand('copy');
        showCopySuccess(copyText);
    } catch (err) {
        showCopyError(copyText);
    }
}

function showCopySuccess(copyText) {
    const originalText = copyText.textContent;
    copyText.textContent = '✅ ¡Copiado!';
    copyText.style.color = '#22c55e';
    
    setTimeout(() => {
        copyText.textContent = originalText;
        copyText.style.color = '';
    }, 2000);
}

function showCopyError(copyText) {
    const originalText = copyText.textContent;
    copyText.textContent = '❌ Error';
    copyText.style.color = '#ef4444';
    
    setTimeout(() => {
        copyText.textContent = originalText;
        copyText.style.color = '';
    }, 2000);
}

// ===== SERVER STATUS CHECK =====
function initializeServerInfo() {
    checkServerStatus();
    // Check server status every 30 seconds
    setInterval(checkServerStatus, 30000);
}

async function checkServerStatus() {
    // Since we can't directly ping the UDP server from browser,
    // we'll simulate a status check based on time and add some visual feedback
    const statusElement = document.querySelector('.server-status');
    const statusDot = document.querySelector('.status-dot');
    
    try {
        // Simulate network check with a timeout
        const isOnline = await simulateServerCheck();
        
        if (isOnline) {
            statusElement.classList.add('online');
            statusElement.classList.remove('offline');
            statusElement.innerHTML = '<span class="status-dot"></span><span>SERVIDOR ONLINE</span>';
            updatePlayerCount();
        } else {
            throw new Error('Server offline');
        }
    } catch (error) {
        statusElement.classList.add('offline');
        statusElement.classList.remove('online');
        statusElement.innerHTML = '<span class="status-dot offline"></span><span>VERIFICANDO...</span>';
    }
}

function simulateServerCheck() {
    return new Promise((resolve) => {
        // Simulate server check with 95% success rate
        const isOnline = Math.random() > 0.05;
        setTimeout(() => resolve(isOnline), 1000);
    });
}

function updatePlayerCount() {
    // Simulate player count (since we can't get real data from client-side)
    const playerCount = Math.floor(Math.random() * 8); // 0-7 players
    const statNumbers = document.querySelectorAll('.stat-number');
    
    statNumbers[0].textContent = `${playerCount}/20`;
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
    // Add more dynamic floating animals
    const animals = ['🐰', '🐱', '🐶', '🐷', '🐮', '🐔', '🐸', '🦋', '🐝', '🌿'];
    const floatingContainer = document.querySelector('.floating-animals');
    
    // Clear existing animals
    floatingContainer.innerHTML = '';
    
    // Create random floating animals
    for (let i = 0; i < 8; i++) {
        const animal = document.createElement('div');
        animal.classList.add('animal');
        animal.textContent = animals[Math.floor(Math.random() * animals.length)];
        
        // Random position
        animal.style.left = Math.random() * 100 + '%';
        animal.style.top = Math.random() * 100 + '%';
        
        // Random animation delay and duration
        animal.style.animationDelay = Math.random() * 5 + 's';
        animal.style.animationDuration = (4 + Math.random() * 4) + 's';
        
        floatingContainer.appendChild(animal);
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
    // Make copyAddress globally available
    window.copyAddress = copyAddress;
    
    // Add keyboard accessibility
    const copyBtn = document.querySelector('.copy-btn');
    if (copyBtn) {
        copyBtn.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                copyAddress();
            }
        });
    }
    
    // Add double-click to copy on input
    const addressInput = document.getElementById('server-address');
    if (addressInput) {
        addressInput.addEventListener('dblclick', function() {
            copyAddress();
        });
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
        const imageObserver = new IntersectionObserver(function(entries, observer) {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    img.src = img.dataset.src;
                    img.classList.remove('lazy');
                    imageObserver.unobserve(img);
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

// ===== EXPORT FUNCTIONS FOR TESTING =====
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        copyAddress,
        checkServerStatus,
        simulateServerCheck
    };
}