// =============================================================================
// CONTROL ADDIN: Simpsons Portrait - Startup Script
// FICHERO: SimpsonsPortrait.startup.js
// =============================================================================
// Este fichero se ejecuta AUTOMÁTICAMENTE cuando BC carga el ControlAddin.
// Su única responsabilidad es:
//   1. Crear la estructura HTML del addin en el DOM del navegador.
//   2. Notificar a AL que el addin está listo mediante ControlAddinReady().
//
// ─────────────────────────────────────────────────────────────────────────────
// ¿POR QUÉ UN SCRIPT DE INICIO SEPARADO?
// ─────────────────────────────────────────────────────────────────────────────
// BC ejecuta el StartupScript UNA SOLA VEZ al inicializar el addin.
// Los ficheros en "Scripts" se cargan como biblioteca pero no se ejecutan
// automáticamente; contienen funciones que AL invoca cuando necesita.
//
// Flujo de vida del ControlAddin:
//   1. BC carga el addin en la página (iframe interno).
//   2. Se ejecuta StartupScript → crea el HTML → llama a ControlAddinReady().
//   3. AL recibe ControlAddinReady() → puede llamar a DisplayPortrait(), etc.
//   4. Cuando AL llama a DisplayPortrait(), se ejecuta la función en Scripts.
// =============================================================================

(function () {
    'use strict';

    // ── 1. Creamos la estructura HTML del addin ───────────────────────────────
    // Modificamos directamente el body del iframe del addin.
    // Esta es la estructura que verá el usuario en la página de BC.
    document.body.innerHTML = [
        '<div id="simpsons-addin-container">',

        '  <!-- Imagen del personaje/lugar -->',
        '  <div id="portrait-wrapper">',
        '    <img id="portrait-img"',
        '         src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"',
        '         alt="Busca un personaje..."',
        '         onerror="this.style.display=\'none\'" />',
        '    <div id="portrait-placeholder">',
        '      <span>🏙️</span>',
        '      <p>Busca un personaje<br>para ver su retrato</p>',
        '    </div>',
        '  </div>',

        '  <!-- Nombre del personaje/lugar -->',
        '  <div id="character-name">Springfield te espera...</div>',

        '  <!-- Separador -->',
        '  <hr id="phrases-divider" style="display:none;" />',

        '  <!-- Sección de frases célebres -->',
        '  <div id="phrases-section" style="display:none;">',
        '    <div id="phrases-title">💬 Frases Célebres</div>',
        '    <div id="phrases-container">',
        '      <!-- Los botones de frases se generan dinámicamente con SetPhrases() -->',
        '    </div>',
        '  </div>',

        '</div>'
    ].join('\n');

    // ── 2. Notificamos a AL que el addin está listo ───────────────────────────
    // InvokeExtensibilityMethod() es la función de BC para comunicarse de
    // JavaScript hacia AL. Dispara el evento "ControlAddinReady" en la página.
    //
    // Parámetros:
    //   1) Nombre del evento (debe coincidir con el declarado en el .al)
    //   2) Array de parámetros (vacío en este caso, el evento no tiene params)
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlAddinReady', []);

})(); // La función se auto-invoca (IIFE pattern) para aislar el scope
