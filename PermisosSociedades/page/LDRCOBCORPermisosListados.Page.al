page 50207 "COBCOR Permisos Listados"
{
    PageType = ListPart;
    SourceTable = "COBCOR Permsisos dinamicos";
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Nombre Permiso"; Rec."Nombre Permiso")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Activo"; Rec."Activo")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        ActualizarUserSetup();
                    end;
                }
            }
        }
    }
    procedure cargarPermisos(pUserId: Code[50])
    var
        Fld: Record Field;
        UserSetup: Record "User Setup";
        UserSetupRecRef: RecordRef;
        FldRef: FieldRef;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        if pUserId = '' then exit;

        if not UserSetup.Get(pUserId) then begin
            UserSetup.Init();
            UserSetup."User ID" := pUserId;
            UserSetup.Insert();
        end;
        UserSetupRecRef.GetTable(UserSetup);
        Fld.SetRange(TableNo, Database::"User Setup");
        Fld.SetFilter("No.", '50000..99999');
        if Fld.FindSet() then
            repeat
                Rec.Init();
                Rec."User ID" := pUserID;
                Rec."Field No." := Fld."No.";
                Rec."Nombre Permiso" := Fld."Field Caption";
                FldRef := UserSetupRecRef.Field(Fld."No.");
                Rec."Activo" := FldRef.Value;
                Rec.Insert();
            until Fld.Next() = 0;
        if Rec.FindFirst() then
            CurrPage.Update(false);
    end;

    local procedure ActualizarUserSetup()
    var
        UserSetup: Record "User Setup";
        UserSetupRecRef: RecordRef;
        FldRef: FieldRef;
    begin
        if UserSetup.Get(Rec."User ID") then begin
            UserSetupRecRef.GetTable(UserSetup);
            FldRef := UserSetupRecRef.Field(Rec."Field No.");
            FldRef.Value := Rec."Activo";
            UserSetupRecRef.Modify(true);
        end;
    end;
}
