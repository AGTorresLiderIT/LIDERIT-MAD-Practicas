window.SetImageUrl = function (url) {
    Message('inicio set img');
    var contenedor = document.getElementById('controlAddIn');
    contenedor.innerHTML = '<img src="' + url + '" style="width: 100%; height: 100%; object-fit: contain;" />';
    Message('post set img');
};