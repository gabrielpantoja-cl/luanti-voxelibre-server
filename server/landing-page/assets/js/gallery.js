// ===== CENTRALIZED GALLERY SYSTEM =====
// Dynamic gallery loading from JSON data source
// Supports both index.html (latest 3-4 images) and galeria.html (all images)

// Gallery data and state
let galleryData = [];
let galleryConfig = {};
let currentImageIndex = 0;
let currentFilter = 'all';
let isIndexPage = false;

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Detect which page we're on
    isIndexPage = window.location.pathname.includes('index.html') || window.location.pathname === '/';

    // Load gallery data from JSON
    loadGalleryData();
});

// Load gallery data from JSON file
async function loadGalleryData() {
    try {
        const response = await fetch('assets/data/gallery-data.json');

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        galleryConfig = data;

        // Sort images by priority (lower number = higher priority)
        galleryData = data.images.sort((a, b) => a.priority - b.priority);

        console.log(`🖼️ Gallery data loaded: ${galleryData.length} images`);

        // Render gallery based on page type
        if (isIndexPage) {
            renderLatestGallery();
        } else {
            renderFullGallery();
        }

        // Initialize gallery features
        initializeGalleryFeatures();

    } catch (error) {
        console.error('❌ Error loading gallery data:', error);
        showGalleryError();
    }
}

// Render latest gallery (for index.html - shows 3-4 latest images)
function renderLatestGallery() {
    const container = document.getElementById('gallery-grid');
    if (!container) return;

    // Clear existing content
    container.innerHTML = '';

    // Get latest 4 images
    const latestImages = galleryData.slice(0, 4);

    latestImages.forEach((image, index) => {
        const galleryItem = createGalleryItem(image, index === 0);
        container.appendChild(galleryItem);
    });

    console.log(`✅ Rendered ${latestImages.length} latest images for index page`);
}

// Render full gallery (for galeria.html - shows all images)
function renderFullGallery() {
    const container = document.getElementById('gallery-full-grid');
    if (!container) return;

    // Clear existing content
    container.innerHTML = '';

    galleryData.forEach((image, index) => {
        const galleryItem = createGalleryItemFull(image, index === 0);
        container.appendChild(galleryItem);
    });

    // Update stats
    updateGalleryStats();

    console.log(`✅ Rendered ${galleryData.length} images for full gallery page`);
}

// Create gallery item for index page
function createGalleryItem(image, isFeatured = false) {
    const div = document.createElement('div');
    div.className = isFeatured ? 'gallery-item featured-main' : 'gallery-item';
    div.dataset.category = image.category;
    div.onclick = () => openGalleryModal(
        `assets/images/${image.filename}`,
        `${image.emoji} ${image.title} - ${image.description}`
    );

    // Build HTML
    div.innerHTML = `
        <img src="assets/images/${image.filename}"
             alt="${image.title} - ${image.description}"
             class="gallery-image">
        <div class="gallery-overlay">
            <div class="gallery-info">
                ${image.badge ? `<div class="gallery-badge ${image.badge.type}">${image.badge.emoji} ${image.badge.text}</div>` : ''}
                <h4>${image.emoji} ${image.title}</h4>
                <p>${image.description}</p>
                <span class="gallery-date">${image.dateLabel}</span>
            </div>
        </div>
    `;

    return div;
}

// Create gallery item for full gallery page
function createGalleryItemFull(image, isFeatured = false) {
    const div = document.createElement('div');
    div.className = isFeatured ? 'gallery-item-full featured-full' : 'gallery-item-full';
    div.dataset.category = image.category;
    div.onclick = () => openGalleryModal(
        `assets/images/${image.filename}`,
        `${image.emoji} ${image.title} - ${image.description}`
    );

    // Build HTML
    div.innerHTML = `
        <img src="assets/images/${image.filename}"
             alt="${image.title} - ${image.description}"
             class="gallery-image-full">
        <div class="gallery-overlay-full">
            <div class="gallery-info-full">
                ${image.badge ? `<div class="gallery-badge ${image.badge.type}">${image.badge.emoji} ${image.badge.text}</div>` : ''}
                <h4>${image.emoji} ${image.title}</h4>
                <p>${image.description}</p>
                <div class="image-meta">
                    <span class="date-tag">${image.dateLabel}</span>
                </div>
            </div>
        </div>
    `;

    return div;
}

// Update gallery statistics (for galeria.html)
function updateGalleryStats() {
    const statsContainer = document.querySelector('.gallery-stats');
    if (!statsContainer) return;

    const totalImages = galleryData.length;
    const latestMonth = galleryData[0]?.dateLabel || 'N/A';

    // Update stat numbers
    const statNumbers = statsContainer.querySelectorAll('.stat-number');
    if (statNumbers[0]) statNumbers[0].textContent = totalImages;
    if (statNumbers[1]) statNumbers[1].textContent = 'Actualizado';

    console.log(`📊 Gallery stats updated: ${totalImages} images, latest: ${latestMonth}`);
}

// Initialize gallery features (modal, navigation, filters)
function initializeGalleryFeatures() {
    setupModalNavigation();
    initializeFilters();
    GalleryUtils.injectStyles();

    // Preload images after a short delay
    setTimeout(() => {
        GalleryUtils.preloadImages();
    }, 1000);
}

// Filter functionality
function initializeFilters() {
    const filterButtons = document.querySelectorAll('.filter-btn');

    filterButtons.forEach(btn => {
        btn.addEventListener('click', function() {
            const filter = this.dataset.filter;

            // Update active button
            filterButtons.forEach(b => b.classList.remove('active'));
            this.classList.add('active');

            // Apply filter
            applyFilter(filter);
        });
    });
}

// Apply filter to gallery
function applyFilter(filter) {
    currentFilter = filter;
    const galleryGrid = document.getElementById('gallery-full-grid');
    const items = galleryGrid?.querySelectorAll('.gallery-item-full') || [];

    let visibleCount = 0;

    items.forEach((item, index) => {
        const category = item.dataset.category;
        const shouldShow = filter === 'all' || category === filter;

        if (shouldShow) {
            item.style.display = 'block';
            item.style.animationDelay = `${visibleCount * 0.1}s`;
            item.classList.add('fade-in');
            visibleCount++;
        } else {
            item.style.display = 'none';
            item.classList.remove('fade-in');
        }
    });

    console.log(`🔍 Filter '${filter}' applied - showing ${visibleCount} items`);
}

// Enhanced modal functionality
function setupModalNavigation() {
    const modal = document.getElementById('gallery-modal');
    const prevBtn = document.getElementById('modal-prev');
    const nextBtn = document.getElementById('modal-next');

    if (!modal) return;

    // Setup navigation buttons
    if (prevBtn && nextBtn) {
        prevBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            navigateGallery(-1);
        });

        nextBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            navigateGallery(1);
        });
    }

    // Keyboard navigation
    document.addEventListener('keydown', function(e) {
        if (modal.classList.contains('active')) {
            switch(e.key) {
                case 'ArrowLeft':
                    e.preventDefault();
                    navigateGallery(-1);
                    break;
                case 'ArrowRight':
                    e.preventDefault();
                    navigateGallery(1);
                    break;
                case 'Escape':
                    e.preventDefault();
                    closeGalleryModal();
                    break;
            }
        }
    });
}

// Navigate gallery images in modal
function navigateGallery(direction) {
    if (galleryData.length <= 1) return;

    // Calculate new index (circular navigation)
    currentImageIndex = (currentImageIndex + direction + galleryData.length) % galleryData.length;
    const newImage = galleryData[currentImageIndex];

    // Update modal
    if (newImage) {
        const modalImage = document.getElementById('gallery-modal-image');
        const modalCaption = document.getElementById('gallery-modal-caption');

        if (modalImage && modalCaption) {
            modalImage.src = `assets/images/${newImage.filename}`;
            modalImage.alt = newImage.title;
            modalCaption.textContent = `${newImage.emoji} ${newImage.title} - ${newImage.description}`;

            // Add loading effect
            modalImage.style.opacity = '0.5';
            modalImage.onload = () => {
                modalImage.style.opacity = '1';
            };
        }
    }
}

// Enhanced open modal function
function openGalleryModal(imageSrc, caption) {
    const modal = document.getElementById('gallery-modal');
    const modalImage = document.getElementById('gallery-modal-image');
    const modalCaption = document.getElementById('gallery-modal-caption');

    if (modal && modalImage && modalCaption) {
        // Find the current image index from filename
        const filename = imageSrc.split('/').pop();
        currentImageIndex = galleryData.findIndex(item => item.filename === filename);
        if (currentImageIndex === -1) currentImageIndex = 0;

        // Update modal content
        modal.classList.add('active');
        modalImage.src = imageSrc;
        modalCaption.textContent = caption;

        // Prevent body scroll
        document.body.style.overflow = 'hidden';

        // Add modal animation class
        modal.classList.add('modal-open');

        console.log(`🖼️ Modal opened for image ${currentImageIndex + 1}/${galleryData.length}`);
    }
}

// Enhanced close modal function
function closeGalleryModal() {
    const modal = document.getElementById('gallery-modal');

    if (modal) {
        modal.classList.add('modal-closing');

        setTimeout(() => {
            modal.classList.remove('active', 'modal-open', 'modal-closing');

            // Restore body scroll
            document.body.style.overflow = '';
        }, 200);
    }
}

// Show error message if gallery fails to load
function showGalleryError() {
    const containers = [
        document.getElementById('gallery-grid'),
        document.getElementById('gallery-full-grid')
    ];

    containers.forEach(container => {
        if (container) {
            container.innerHTML = `
                <div style="grid-column: 1 / -1; text-align: center; padding: 3rem;">
                    <div style="font-size: 3rem; margin-bottom: 1rem;">😢</div>
                    <h3>Error al cargar la galeria</h3>
                    <p>Por favor, recarga la pagina o contacta a los administradores.</p>
                </div>
            `;
        }
    });
}

// Gallery utilities
const GalleryUtils = {
    // Add fade-in animation CSS
    injectStyles: function() {
        const style = document.createElement('style');
        style.textContent = `
            .fade-in {
                animation: fadeInUp 0.6s ease-out forwards;
            }

            @keyframes fadeInUp {
                from {
                    opacity: 0;
                    transform: translateY(20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .modal-open {
                animation: modalFadeIn 0.3s ease-out;
            }

            .modal-closing {
                animation: modalFadeOut 0.2s ease-in;
            }

            @keyframes modalFadeIn {
                from { opacity: 0; }
                to { opacity: 1; }
            }

            @keyframes modalFadeOut {
                from { opacity: 1; }
                to { opacity: 0; }
            }

            .gallery-item-full {
                transition: all 0.3s ease;
            }

            .gallery-item-full:not([style*="display: none"]) {
                animation: slideInUp 0.5s ease-out forwards;
            }

            @keyframes slideInUp {
                from {
                    opacity: 0;
                    transform: translateY(30px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
        `;
        document.head.appendChild(style);
    },

    // Preload images for better performance
    preloadImages: function() {
        galleryData.forEach(item => {
            const img = new Image();
            img.src = `assets/images/${item.filename}`;
        });
        console.log('🚀 Gallery images preloaded');
    },

    // Get gallery statistics
    getStats: function() {
        const stats = {
            total: galleryData.length,
            updates: galleryData.filter(item => item.category === 'updates').length,
            community: galleryData.filter(item => item.category === 'community').length,
            gameplay: galleryData.filter(item => item.category === 'gameplay').length
        };

        console.log('📊 Gallery stats:', stats);
        return stats;
    }
};

// Make functions available globally for onclick handlers
window.openGalleryModal = openGalleryModal;
window.closeGalleryModal = closeGalleryModal;
window.navigateGallery = navigateGallery;

// Export for potential module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        loadGalleryData,
        applyFilter,
        navigateGallery,
        GalleryUtils
    };
}
