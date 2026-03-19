// =============================================================================
// PERMISSION SET: Simpsons API
// =============================================================================
// Propósito:
//   Define los permisos mínimos necesarios para que un usuario pueda
//   utilizar la integración con la API de los Simpsons (Burnsiness Central).
//
//   En BC Cloud es OBLIGATORIO definir permission sets para todos los
//   objetos de tu extensión (especialmente tablas). Sin un permission set,
//   el compilador emite un error de análisis.
//
//   Dos niveles de acceso:
//     SIMPSONS-READ  → Solo lectura (ver la lista de personajes)
//     SIMPSONS-ALL   → Acceso completo (importar, buscar, guardar personajes)
// =============================================================================

permissionset 50000 "Simpsons API"
{
    Caption = 'Simpsons API - Acceso Completo';
    // Assignable = true permite que los administradores asignen este permission set
    // directamente a usuarios desde la página "Conjuntos de permisos de usuario".
    Assignable = true;

    Permissions =
    // ── Tabla Characters: permisos CRUD completos ─────────────────────────
    // R = Read, I = Insert, M = Modify, D = Delete
    // X = Execute (para codeunits)
    table Characters = X,
    tabledata Characters = RIMD,

    // ── Páginas: permiso de ejecución ─────────────────────────────────────
    page "Characters List" = X,
    page "Habitante de Springfield" = X,
    page "Paseo de Perros" = X,

    // ── Codeunit: permiso de ejecución ────────────────────────────────────
    codeunit "Simpsons API" = X;
}
