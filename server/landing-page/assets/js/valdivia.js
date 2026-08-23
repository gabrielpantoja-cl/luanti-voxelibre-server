(() => {
    const menuButton = document.querySelector("#menu-button");
    const menu = document.querySelector("#site-menu");
    const feedback = document.querySelector("#copy-feedback");

    if (menuButton && menu) {
        menuButton.addEventListener("click", () => {
            const open = menu.classList.toggle("is-open");
            menuButton.setAttribute("aria-expanded", String(open));
        });

        menu.querySelectorAll("a").forEach((link) => link.addEventListener("click", () => {
            menu.classList.remove("is-open");
            menuButton.setAttribute("aria-expanded", "false");
        }));
    }

    document.querySelectorAll("[data-copy]").forEach((button) => {
        button.addEventListener("click", async () => {
            const value = button.dataset.copy;
            try {
                await navigator.clipboard.writeText(value);
                if (feedback) feedback.textContent = `Copiado: ${value}`;
            } catch {
                if (feedback) feedback.textContent = "No se pudo copiar automáticamente; selecciona el texto manualmente.";
            }
        });
    });
})();
