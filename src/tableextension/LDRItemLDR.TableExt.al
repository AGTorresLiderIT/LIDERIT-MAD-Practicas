tableextension 50000 "LDR_ItemLDR" extends Item
{
    fields
    {
        field(50000; LDR_Material; Code[20])
        {
            Caption = 'Material';
            DataClassification = ToBeClassified;
            //TableRelation = LDR_Materiales.Codigo where(Bloqueado = const(false));
            TableRelation = LDR_Materiales.Codigo;

            trigger OnValidate()
            var
                Materiales: Record LDR_Materiales;
            begin
                //yo tengo el valor de "mi material" en el campo Rec."LDR_Material"

                //Para traspasar el valor de lo seleccionado a la variable

                // 1 - Es la PK
                Materiales.get(Rec.LDR_Material);

                // 2 - SetRange - Filtra con el tipo de campo que es,
                //Materiales.SetRange(Codigo, Rec.LDR_Material);

                //Materiales.SetRange(Bloqueado, false);

                //Materiales.SetRange(Descripcion, 'Aluminio');

                // 2.1 - SetFilter - Filtra siempre como texto
                //Materiales.SetFilter(Codigo, Rec.LDR_Material);

                //Materiales.SetFilter(Bloqueado, 'true');

                //Materiales.SetFilter(Descripcion,'*minio*|cobre|*pla*');


                if Materiales.Bloqueado then
                    Error('El Material %1 está bloqueado.', Rec.LDR_Material + ' - ' + Materiales.Descripcion);
            end;

        }
        field(50001; LDR_Pais; Code[10])
        {
            Caption = 'Pais';
            DataClassification = ToBeClassified;
            TableRelation = "Country/Region".Code;
        }
    }
}
