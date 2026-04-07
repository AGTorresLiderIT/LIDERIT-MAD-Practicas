controladdin "Fotos"
{
    RequestedHeight = 350;
    RequestedWidth = 350;
    VerticalStretch = true;
    HorizontalStretch = true;

    StartupScript = 'js/startup.js';
    Scripts = 'js/script.js';

    event ControlListo();

    procedure InsertarFoto(url: Text);
}