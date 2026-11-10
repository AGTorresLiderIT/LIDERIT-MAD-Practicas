function MostrarImagen(url) {
    var cont = document.getElementById('controlAddIn');
    cont.innerHTML = '<img src="' + url + '" style="max-width:100%; max-height:280px;">';
}

function Hablar(texto) {
    window.speechSynthesis.cancel();
    var voz = new SpeechSynthesisUtterance(texto);
    voz.lang = 'es-ES';
    window.speechSynthesis.speak(voz);
}

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('Ready', []);