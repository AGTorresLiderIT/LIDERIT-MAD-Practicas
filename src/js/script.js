function InsertarFoto(url) {
    var contenedor = document.getElementById('controlAddIn');
    contenedor.innerHTML = '<img src="' + url + '" style="width: 100%; height: 100%; object-fit: contain;" />';
}
function Speak(text) {
    if (!window.speechSynthesis) {
        console.warn('Speech synthesis no está disponible en este navegador.');
        return;
    }
    if (text === null || text === undefined) {
        return;
    }

    var message = typeof text === 'string' ? text : String(text);
    var utterance = new SpeechSynthesisUtterance(message);
    window.speechSynthesis.speak(utterance);
}