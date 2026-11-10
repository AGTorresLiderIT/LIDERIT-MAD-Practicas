controladdin "Simpsons Addin_LDR"
{
    RequestedHeight = 300;
    RequestedWidth = 300;
    Scripts = 'script.js';

    event Ready();
    procedure MostrarImagen(Url: Text);
    procedure Hablar(Texto: Text);
}