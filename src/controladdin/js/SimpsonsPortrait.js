// =============================================================================
// CONTROL ADDIN: Simpsons Portrait - Funciones principales
// FICHERO: SimpsonsPortrait.js
// =============================================================================
// Este fichero contiene las funciones que AL puede invocar desde BC.
// Cuando AL llama a  CurrPage.MiAddin.DisplayPortrait(url, nombre),
// BC ejecuta la función "DisplayPortrait" definida aquí.
//
// ─────────────────────────────────────────────────────────────────────────────
// WEB SPEECH API (síntesis de voz):
// ─────────────────────────────────────────────────────────────────────────────
// Para "reproducir" las frases de los personajes usamos la Web Speech API,
// disponible de forma nativa en Chrome, Edge y Firefox modernos.
// NO requiere ninguna librería externa ni costo adicional.
//
// Uso básico:
//   var utterance = new SpeechSynthesisUtterance("Texto a leer");
//   utterance.lang = 'en-US';
//   window.speechSynthesis.speak(utterance);
// =============================================================================

'use strict';

// ── Variable global para la frase que se está reproduciendo ──────────────────
// La declaramos fuera de las funciones para que sea accesible desde los botones
// generados dinámicamente en SetPhrases().
var currentlyPlayingButton = null;

// =============================================================================
// FUNCIÓN: DisplayPortrait
// Llamada desde AL: CurrPage.MiAddin.DisplayPortrait(imageUrl, name)
// =============================================================================
// Actualiza la imagen y el nombre del personaje/lugar en el addin.
function DisplayPortrait(imageUrl, name) {
    var img = document.getElementById('portrait-img');
    var placeholder = document.getElementById('portrait-placeholder');
    var nameLabel = document.getElementById('character-name');

    if (!img || !nameLabel) return; // Seguridad: el DOM puede no estar listo

    // ── Actualizamos el nombre (lo hacemos antes para que aparezca siempre) ──
    nameLabel.textContent = name || '';

    // ── Actualizamos la imagen ────────────────────────────────────────────
    if (imageUrl && imageUrl !== '') {

        // ESTRATEGIA: Mantenemos el placeholder visible mientras la imagen carga.
        // Solo la ocultamos si la imagen carga correctamente (onload).
        // Si falla (onerror), mostramos el placeholder con un enlace de fallback.
        img.style.display = 'none';
        if (placeholder) {
            placeholder.innerHTML = '<span>⏳</span><p>Cargando retrato...</p>';
            placeholder.style.display = 'flex';
        }

        // ── onload: la imagen llegó bien ─────────────────────────────────
        img.onload = function () {
            img.style.display = 'block';
            if (placeholder) placeholder.style.display = 'none';
        };

        // ── onerror: la imagen fue bloqueada (CSP/CORS) o la URL no existe ─
        // Esto ocurre frecuentemente en BC SaaS porque el Content Security
        // Policy del navegador bloquea imágenes de dominios externos cargadas
        // desde iframes de ControlAddins.
        //
        // Solución: mostramos un enlace para abrir la imagen en pestaña nueva.
        img.onerror = function () {
            img.style.display = 'none';
            if (placeholder) {
                placeholder.innerHTML =
                    '<span>🖼️</span>' +
                    '<p>No se puede mostrar la imagen aquí.<br>' +
                    '<a href="' + imageUrl + '" target="_blank" ' +
                    '   style="color:#003594;font-weight:bold;">Ver retrato ↗</a></p>';
                placeholder.style.display = 'flex';
            }
        };

        img.alt = name || 'Personaje de Springfield';
        img.src = imageUrl; // Asignamos src DESPUÉS de definir onload/onerror

    } else {
        // Sin URL de imagen: placeholder por defecto
        img.style.display = 'none';
        if (placeholder) {
            placeholder.innerHTML = '<span>🏙️</span><p>Busca un personaje<br>para ver su retrato</p>';
            placeholder.style.display = 'flex';
        }
    }
}

// =============================================================================
// FUNCIÓN: SetPhrases
// Llamada desde AL: CurrPage.MiAddin.SetPhrases(phrasesText)
// =============================================================================
// Recibe el texto de frases separadas por " • " y crea un botón
// de reproducción para cada una.
function SetPhrases(phrasesText) {
    var container = document.getElementById('phrases-container');
    var section = document.getElementById('phrases-section');
    var divider = document.getElementById('phrases-divider');

    if (!container) return;

    // ── Limpiamos los botones anteriores ──────────────────────────────────
    container.innerHTML = '';
    stopCurrentSpeech(); // Paramos cualquier reproducción en curso

    // ── Verificamos que hay frases ────────────────────────────────────────
    if (!phrasesText || phrasesText.trim() === '' ||
        phrasesText.indexOf('no tiene frases') >= 0) {
        if (section) section.style.display = 'none';
        if (divider) divider.style.display = 'none';
        return;
    }

    // ── Separamos las frases por el separador " • " ───────────────────────
    var phrases = phrasesText.split(' • ').filter(function (p) {
        return p.trim() !== '';
    });

    if (phrases.length === 0) {
        if (section) section.style.display = 'none';
        if (divider) divider.style.display = 'none';
        return;
    }

    // ── Mostramos la sección de frases ────────────────────────────────────
    if (section) section.style.display = 'block';
    if (divider) divider.style.display = 'block';

    // ── Creamos un botón para cada frase ─────────────────────────────────
    // Limitamos a las primeras 8 frases para no sobrecargar la UI.
    var maxPhrases = Math.min(phrases.length, 8);

    for (var i = 0; i < maxPhrases; i++) {
        var phrase = phrases[i].trim();
        if (!phrase) continue;

        // Cada frase tiene su propio div con el texto y un botón de play/stop
        var phraseDiv = document.createElement('div');
        phraseDiv.className = 'phrase-item';

        // Texto de la frase (truncado si es muy largo)
        var phraseText = document.createElement('span');
        phraseText.className = 'phrase-text';
        phraseText.title = phrase; // Tooltip con la frase completa
        phraseText.textContent = phrase.length > 60
            ? phrase.substring(0, 57) + '...'
            : phrase;

        // Botón de reproducción
        var playBtn = document.createElement('button');
        playBtn.className = 'phrase-play-btn';
        playBtn.textContent = '🔊';
        playBtn.title = 'Reproducir: ' + phrase;
        playBtn.setAttribute('data-phrase', phrase); // Guardamos la frase en el botón

        // Event listener del botón: reproduce o para la frase
        // Usamos una IIFE para capturar la variable "phrase" correctamente en el bucle
        (function (btn, currentPhrase) {
            btn.addEventListener('click', function () {
                speakPhrase(currentPhrase, btn);
            });
        })(playBtn, phrase);

        phraseDiv.appendChild(phraseText);
        phraseDiv.appendChild(playBtn);
        container.appendChild(phraseDiv);
    }

    // Si hay más frases de las mostradas, indicamos cuántas quedan
    if (phrases.length > maxPhrases) {
        var moreDiv = document.createElement('div');
        moreDiv.className = 'phrases-more';
        moreDiv.textContent = '... y ' + (phrases.length - maxPhrases) + ' frases más';
        container.appendChild(moreDiv);
    }
}

// =============================================================================
// FUNCIÓN INTERNA: speakPhrase
// Esta función NO es llamada por AL, es interna del JavaScript.
// Se ejecuta cuando el usuario pulsa un botón de frase.
// =============================================================================
function speakPhrase(phrase, button) {
    // ── Verificamos soporte del navegador ──────────────────────────────────
    if (!('speechSynthesis' in window)) {
        alert('Tu navegador no soporta síntesis de voz (Web Speech API).\n' +
            'Prueba con Google Chrome o Microsoft Edge.');
        return;
    }

    // ── Si ya se está reproduciendo esta frase, la paramos ────────────────
    if (currentlyPlayingButton === button && window.speechSynthesis.speaking) {
        stopCurrentSpeech();
        return;
    }

    // ── Paramos cualquier reproducción anterior ────────────────────────────
    stopCurrentSpeech();

    // ── Creamos y configuramos la locución ────────────────────────────────
    // SpeechSynthesisUtterance representa una frase para ser leída en voz alta.
    var utterance = new SpeechSynthesisUtterance(phrase);
    utterance.lang = 'en-US';   // Los personajes de Springfield hablan inglés
    utterance.rate = 0.9;        // Velocidad ligeramente reducida para mayor claridad
    utterance.pitch = 1.0;       // Tono natural
    utterance.volume = 1.0;      // Volumen máximo

    // ── Actualizamos el estado visual del botón ────────────────────────────
    button.textContent = '⏹️'; // Cambiamos el ícono a "parar"
    button.classList.add('playing');
    currentlyPlayingButton = button;

    // ── Cuando termina la reproducción, restauramos el botón ──────────────
    utterance.onend = function () {
        if (currentlyPlayingButton === button) {
            button.textContent = '🔊';
            button.classList.remove('playing');
            currentlyPlayingButton = null;
        }
    };

    utterance.onerror = function () {
        button.textContent = '🔊';
        button.classList.remove('playing');
        currentlyPlayingButton = null;
    };

    // ── Iniciamos la reproducción ─────────────────────────────────────────
    window.speechSynthesis.speak(utterance);

    // ── Notificamos a AL que se está reproduciendo una frase ──────────────
    // Esto dispara el evento PhraseButtonClicked en la página de BC.
    // AL puede usar este evento para hacer logs, analytics, etc.
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('PhraseButtonClicked', [phrase]);
}

// =============================================================================
// FUNCIÓN INTERNA: stopCurrentSpeech
// Para cualquier reproducción de voz en curso.
// =============================================================================
function stopCurrentSpeech() {
    if (window.speechSynthesis && window.speechSynthesis.speaking) {
        window.speechSynthesis.cancel();
    }
    if (currentlyPlayingButton) {
        currentlyPlayingButton.textContent = '🔊';
        currentlyPlayingButton.classList.remove('playing');
        currentlyPlayingButton = null;
    }
}
