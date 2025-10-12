// ===== ENHANCED GALLERY FUNCTIONALITY =====
// Additional JavaScript for gallery page functionality

// Gallery data and state
let galleryData = [];
let currentImageIndex = 0;
let currentFilter = 'all';

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeGallery();
    initializeFilters();
    setupGalleryNavigation();
});

// Initialize gallery system
function initializeGallery() {
    // Collect all gallery items
    collectGalleryData();

    // Setup initial filter
    applyFilter(currentFilter);

    // Initialize modal navigation
    setupModalNavigation();
}

// Collect gallery data for navigation
function collectGalleryData() {
    const galleryItems = document.querySelectorAll('.gallery-item-full, .gallery-item');

    galleryData = Array.from(galleryItems).map((item, index) => {
        const img = item.querySelector('img');
        const title = item.querySelector('h4')?.textContent || 'Imagen sin título';

        return {
            index: index,
            src: img?.src || '',
            alt: img?.alt || title,
            title: title,
            description: item.querySelector('p')?.textContent || '',
            category: item.dataset.category || 'all',
            element: item
        };
    });

    console.log(`🖼️ Gallery initialized with ${galleryData.length} images`);
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

    // Update visible gallery data
    updateVisibleGalleryData();
}

// Update visible gallery data for navigation
function updateVisibleGalleryData() {
    const visibleItems = galleryData.filter(item => {
        return currentFilter === 'all' || item.category === currentFilter;
    });

    // Update indices for visible items
    visibleItems.forEach((item, index) => {
        item.visibleIndex = index;
    });

    return visibleItems;
}

// Enhanced modal functionality
function setupModalNavigation() {
    const modal = document.getElementById('gallery-modal');
    const modalImage = document.getElementById('gallery-modal-image');
    const modalCaption = document.getElementById('gallery-modal-caption');
    const prevBtn = document.getElementById('modal-prev');
    const nextBtn = document.getElementById('modal-next');

    if (!modal || !modalImage || !modalCaption) return;

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
    const visibleItems = updateVisibleGalleryData();

    if (visibleItems.length <= 1) return; // No navigation needed

    // Find current image index in visible items
    let currentVisibleIndex = visibleItems.findIndex(item => item.index === currentImageIndex);

    // Calculate new index
    currentVisibleIndex = (currentVisibleIndex + direction + visibleItems.length) % visibleItems.length;
    const newItem = visibleItems[currentVisibleIndex];

    // Update modal
    if (newItem) {
        updateModalContent(newItem.src, newItem.title, newItem.description);
        currentImageIndex = newItem.index;

        // Update navigation buttons
        updateNavigationButtons(currentVisibleIndex, visibleItems.length);
    }
}

// Update modal content
function updateModalContent(src, title, description) {
    const modalImage = document.getElementById('gallery-modal-image');
    const modalCaption = document.getElementById('gallery-modal-caption');

    if (modalImage && modalCaption) {
        modalImage.src = src;
        modalImage.alt = title;
        modalCaption.textContent = `${title} - ${description}`;

        // Add loading effect
        modalImage.style.opacity = '0.5';
        modalImage.onload = () => {
            modalImage.style.opacity = '1';
        };
    }
}

// Update navigation button states
function updateNavigationButtons(currentIndex, totalItems) {
    const prevBtn = document.getElementById('modal-prev');
    const nextBtn = document.getElementById('modal-next');

    if (prevBtn && nextBtn) {
        // In a circular navigation, buttons are never disabled
        prevBtn.disabled = false;
        nextBtn.disabled = false;

        // Update button text with context
        prevBtn.textContent = `← Anterior (${currentIndex + 1}/${totalItems})`;
        nextBtn.textContent = `Siguiente (${((currentIndex + 1) % totalItems) + 1}/${totalItems}) →`;
    }
}

// Enhanced open modal function
function openGalleryModal(imageSrc, caption) {
    const modal = document.getElementById('gallery-modal');
    const modalImage = document.getElementById('gallery-modal-image');
    const modalCaption = document.getElementById('gallery-modal-caption');

    if (modal && modalImage && modalCaption) {
        // Find the current image index
        currentImageIndex = galleryData.findIndex(item => item.src === imageSrc) || 0;

        // Update modal content
        modal.classList.add('active');
        modalImage.src = imageSrc;
        modalCaption.textContent = caption;

        // Setup navigation for this specific image
        const visibleItems = updateVisibleGalleryData();
        const currentVisibleIndex = visibleItems.findIndex(item => item.src === imageSrc) || 0;
        updateNavigationButtons(currentVisibleIndex, visibleItems.length);

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
            img.src = item.src;
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

// Navigation setup for header links
function setupGalleryNavigation() {
    // Update active nav link
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
        if (link.textContent.includes('Galería Completa')) {
            link.classList.add('active');
        } else {
            link.classList.remove('active');
        }
    });
}

// Initialize additional features when page loads
document.addEventListener('DOMContentLoaded', function() {
    // Inject additional styles
    GalleryUtils.injectStyles();

    // Preload images after a short delay
    setTimeout(() => {
        GalleryUtils.preloadImages();
    }, 1000);

    // Log gallery statistics
    setTimeout(() => {
        GalleryUtils.getStats();
    }, 500);

    // Setup smooth scrolling for any anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
});

// Make functions available globally for onclick handlers
window.openGalleryModal = openGalleryModal;
window.closeGalleryModal = closeGalleryModal;
window.navigateGallery = navigateGallery;

// Export for potential module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        initializeGallery,
        applyFilter,
        navigateGallery,
        GalleryUtils
    };
}