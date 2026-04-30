permissionset 50200 GeneratedPermission
{
    Assignable = true;
    Permissions = tabledata "App Deployment Staging" = RIMD,
        tabledata Eliminaralcopiar = RIMD,
        table "App Deployment Staging" = X,
        table Eliminaralcopiar = X,
        codeunit "App Deployment Management" = X,
        codeunit EliminarAlClonar = X,
        page "App Deploy Error FactBox" = X,
        page "App Deployment Card" = X,
        page "App Deployment Staging" = X,
        page "Deployment Group Apps" = X,
        page "Deployment Group Detail" = X,
        page "Deployment Group Wizard" = X,
        page "Deployment Groups" = X,
        tabledata Configuracion = RIMD,
        table Configuracion = X,
        codeunit DesactivarUsuariosAlCopiarEnto = X,
        tabledata config = RIMD,
        table config = X,
        codeunit BorrarDatosCopiarEntorno = X,
        tabledata "Job Queue Request" = RIMD,
        table "Job Queue Request" = X,
        codeunit MensajeEntorno = X,
        page config = X,
        page "Job Queue Request API" = X,
        codeunit pruebaapifinal = X;
}