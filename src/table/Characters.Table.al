// =============================================================================
// TABLA: Characters (Personajes)
// OBJETO: Table 50000
// =============================================================================
// Propósito:
//   Esta es una tabla PERSISTENTE (se guarda en la base de datos de BC).
//   Actúa como caché local de personajes importados desde la API de los Simpsons.
//   Almacena únicamente los datos identificativos: ID, nombre y fecha de carga.
//   Los datos detallados (ocupación, frases, foto, etc.) se consultan en tiempo
//   real contra la API desde la página "Habitante de Springfield".
// =============================================================================

table 50000 Characters
{
  Caption = 'Characters';
  // DataClassification es obligatorio en BC Cloud.
  // CustomerContent = datos introducidos o gestionados por el usuario.
  DataClassification = CustomerContent;

  fields
  {
    // -------------------------------------------------------------------------
    // Campo 1: ID Personaje
    // Clave primaria. Usamos el ID que nos devuelve la API (entero positivo).
    // Ej: Homer Simpson → ID 1, Marge Simpson → ID 2, etc.
    // -------------------------------------------------------------------------
    field(1; "ID Personaje"; Integer)
    {
      Caption = 'ID Personaje';
      DataClassification = CustomerContent;
    }

    // -------------------------------------------------------------------------
    // Campo 2: Nombre Personaje
    // Nombre completo tal y como lo devuelve la API.
    // Ej: "Homer Simpson", "Bart Simpson", "Charles Montgomery Burns"
    // -------------------------------------------------------------------------
    field(2; "Nombre Personaje"; Text[100])
    {
      Caption = 'Nombre Personaje';
      DataClassification = CustomerContent;
    }

    // -------------------------------------------------------------------------
    // Campo 3: Fecha Actualización
    // Marca temporal de la última vez que se importó/actualizó este registro
    // desde la API. Útil para saber si los datos están desactualizados.
    // DateTime en BC = fecha + hora combinados (siempre en UTC internamente).
    // -------------------------------------------------------------------------
    field(3; "Fecha Actualización"; DateTime)
    {
      Caption = 'Fecha Actualización';
      DataClassification = CustomerContent;
    }
  }

  keys
  {
    // La clave primaria (PK) identifica de forma única cada registro.
    // Clustered = true significa que la tabla se ordena físicamente por esta clave.
    // Solo puede haber UNA clave clustered por tabla.
    key(PK; "ID Personaje")
    {
      Clustered = true;
    }

    // Clave secundaria para búsquedas/ordenación por nombre.
    // Útil cuando el usuario quiere buscar personajes por nombre en la lista.
    key(NombrePersonaje; "Nombre Personaje") { }
  }
}
