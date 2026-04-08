controladdin SimpsonsImageViewer
{
    RequestedHeight = 350;
    RequestedWidth = 350;
    VerticalStretch = true;
    HorizontalStretch = true;

    Scripts = 'script.js';
    StartupScript = 'startup.js';

    event Control();

    procedure SetImageUrl(url: Text);
}