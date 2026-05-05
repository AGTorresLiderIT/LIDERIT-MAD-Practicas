table 50250 "Eliminaralcopiar"
{
    Caption = 'Eliminaralcopiar';
    DataPerCompany = false;
    ReplicateData = false;
    InherentEntitlements = rX;
    InherentPermissions = rX;
    Permissions = tabledata "Eliminaralcopiar" = r;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            TableRelation = Company;
        }
        field(2; Enabled; Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            begin
                OnEnabled("Company Name", Enabled);
            end;
        }
    }
    keys
    {
        key(Key1; "Company Name")
        {
            Clustered = true;
        }
    }

    procedure SetEnabled(CompanyName: Text[30]; Enable: Boolean)
    var
        AssistedCompanySetupStatus: Record Eliminaralcopiar;
    begin
        if not AssistedCompanySetupStatus.Get(CompanyName) then begin
            AssistedCompanySetupStatus.Init();
            AssistedCompanySetupStatus.Validate("Company Name", CompanyName);
            AssistedCompanySetupStatus.Validate(Enabled, Enable);
            AssistedCompanySetupStatus.Insert();
        end else begin
            AssistedCompanySetupStatus.Validate(Enabled, Enable);
            AssistedCompanySetupStatus.Modify();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnEnabled(SetupCompanyName: Text[30]; AssistedSetupEnabled: Boolean)
    begin
    end;

}