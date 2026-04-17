// codeunit 50203 BorrarDatosCopiarEntorno
// {

//     //no va asi que a buscar otro evento

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", OnClearCompanyConfig, '', false, false)]
//     local procedure "Environment Cleanup_OnClearCompanyConfig"(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
//     var
//         PaymentMethod: Record "Payment Method";
//         PaymentTerms: Record "Payment Terms";
//     begin
//         PaymentMethod.ChangeCompany(CompanyName);
//         PaymentMethod.DeleteAll();

//         PaymentTerms.ChangeCompany(CompanyName);
//         PaymentTerms.ModifyAll(Description, 'Sandbox Description');
//     end;
// }
