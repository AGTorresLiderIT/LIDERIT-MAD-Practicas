function InsertarFoto(url) {
    var contenedor = document.getElementById('controlAddIn');
    contenedor.innerHTML = '<img src="' + url + '" style="width: 100%; height: 100%; object-fit: contain;" />';
}