document.addEventListener('DOMContentLoaded', () => {
    const navToggle = document.getElementById('nav-toggle');
    const mobileNav = document.getElementById('mobile-nav');
    const body = document.body;

    if (navToggle && mobileNav) {
        navToggle.addEventListener('click', () => {
            body.classList.toggle('nav-open');
        });
    }
});
