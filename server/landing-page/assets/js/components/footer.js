/**
 * Footer Component
 * Shared footer for all pages with updated server commands
 */
export function Footer() {
    return `
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
                        <li>Tipo: Creativo, PvP solo en arenas</li>
                    </ul>
                </div>

                <div class="footer-section">
                    <h4>Comandos</h4>
                    <ul>
                        <li><code>/back_to_spawn</code> - Volver al spawn</li>
                        <li><code>/reglas</code> - Ver las reglas</li>
                        <li><code>/protect [nombre]</code> - Proteger tu construccion</li>
                        <li><code>/sit</code> - Sentarse</li>
                        <li><code>/lay</code> - Recostarse</li>
                        <li><code>/?</code> - Ver todos los comandos</li>
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
}
