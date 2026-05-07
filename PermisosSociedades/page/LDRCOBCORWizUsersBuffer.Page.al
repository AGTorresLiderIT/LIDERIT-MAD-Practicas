page 50359 COBCORWizUsersBuffer
{
    ApplicationArea = All;
    Caption = 'COBCORWizUsersBuffer', Comment = 'ESP="Lista de Usuarios Wizard X País"';
    PageType = List;
    SourceTable = COBCORWizUsersBuffer;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(COBCORCompanyName; Rec.COBCORCompanyName)
                {
                    ToolTip = 'Specifies the value of the Company Name field.', Comment = 'ESP="Nombre Empresa"';
                }
                field(COBCORCountry; Rec.COBCORCountry)
                {
                    ToolTip = 'Specifies the value of the Company Name field.', Comment = 'ESP="País sociedad"';
                }
                field(COBCORUserID; Rec.COBCORUserID)
                {
                    ToolTip = 'Specifies the value of the User ID field.', Comment = 'ESP="ID Usuario"';
                }
                field(COBCORFullName; Rec.COBCORFullName)
                {
                    ToolTip = 'Specifies the value of the Full Name.', Comment = 'ESP="Nombre Completo"';
                }
                field(COBCORLicenseType; Rec.COBCORLicenseType)
                {
                    ToolTip = 'Specifies the value of the Company Role field.', Comment = 'ESP="Tipo de Licencia"';
                }
                field(COBCORCompanyRole; Rec.COBCORCompanyRole)
                {
                    ToolTip = 'Specifies the value of the Company Role field.', Comment = 'ESP="Rol Actual"';
                }
                field(COBCORDescriptionRole; Rec.COBCORDescriptionRole)
                {
                    ToolTip = 'Specifies the value of the Company Role field.', Comment = 'ESP="Descripción Rol"';
                }
                field(COBCOROKRole; Rec.COBCOROKRole)
                {
                    ToolTip = 'Specifies the value of the Company Role field.', Comment = 'ESP="Rol Correcto"';
                }
                field(COBCORCurrentDelegations; Rec.COBCORCurrentDelegations)
                {
                    ToolTip = 'Specifies the value of the User Country field.', Comment = 'ESP="Delegaciones Actuales"';
                }
                field(COBCOROKDelegations; Rec.COBCOROKDelegations)
                {
                    ToolTip = 'Specifies the value of the User Country field.', Comment = 'ESP="Delegaciones Correctas"';
                }
                field(COBCORCurrentSituation; Rec.COBCORCurrentSituation)
                {
                    ToolTip = 'Specifies the value of the User Country field.', Comment = 'ESP="Situación actual"';
                }
                field(COBCORCancelWizard; Rec.COBCORCancelWizard)
                {
                    ToolTip = 'Specifies the value of the Company Role field.', Comment = 'ESP="Baja Wizard"';
                }
                field(COBCOREmail; Rec.COBCOREmail)
                {
                    ToolTip = 'Specifies the value of the Company Role field.', Comment = 'ESP="Email"';
                }
            }
        }
    }
}
