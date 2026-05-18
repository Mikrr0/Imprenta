/// [RF2] [RF13] Configuración centralizada del sistema de gestión de imprenta
/// Contiene listas predefinidas, mapeos y constantes globales
class AppConfig {
  // ═══════════════════════════════════════════════════════════════
  // [RF2] Cargos disponibles del sistema
  // ═══════════════════════════════════════════════════════════════
  static const List<String> cargosOperativos = [
    'Operario de Impresión',
    'Operario de Corte',
    'Encargado de Bodega',
  ];

  static const List<String> cargosJerarquicos = [
    'Jefe de Taller',
    'Administrador',
    'Gerente',
  ];

  static const List<String> todosCargos = [
    ...cargosOperativos,
    ...cargosJerarquicos,
  ];

  // ═══════════════════════════════════════════════════════════════
  // [RF13] Roles de seguridad disponibles
  // ═══════════════════════════════════════════════════════════════
  static const List<String> todosRoles = [
    'Operario',
    'Jefe',
    'Administrador',
    'Gerente',
  ];

  // ═══════════════════════════════════════════════════════════════
  // [RF2] [RF13] Mapeo: Cargo → Roles permitidos
  // Define qué roles pueden asignarse a cada cargo
  // ═══════════════════════════════════════════════════════════════
  static const Map<String, List<String>> cargoRolesMap = {
    'Operario de Impresión': ['Operario'],
    'Operario de Corte': ['Operario'],
    'Encargado de Bodega': ['Operario', 'Jefe'],
    'Jefe de Taller': ['Jefe', 'Administrador'],
    'Administrador': ['Administrador', 'Gerente'],
    'Gerente': ['Gerente'],
  };

  // ═══════════════════════════════════════════════════════════════
  // [RF2] Restricciones salariales y operativas
  // ═══════════════════════════════════════════════════════════════
  static const double sueldoMinimoLegal = 460000;

  // Validaciones de longitud de campos
  static const int nombreMinChars = 3;
  static const int nombreMaxChars = 100;

  // Tiempos de respuesta esperados [RNF1] [RNF10]
  static const Duration timeoutValidacion = Duration(seconds: 5);

  // Constructor privado para evitar instanciación
  AppConfig._();

  /// Obtiene los roles permitidos para un cargo específico
  static List<String> getRolesParaCargo(String cargo) {
    return cargoRolesMap[cargo] ?? [];
  }

  /// Valida si un cargo existe en el sistema
  static bool cargoValido(String cargo) {
    return todosCargos.contains(cargo);
  }

  /// Valida si un rol existe en el sistema
  static bool rolValido(String rol) {
    return todosRoles.contains(rol);
  }

  /// Valida si la combinación cargo-rol es válida
  static bool combinacionValida(String cargo, String rol) {
    final rolesPermitidos = getRolesParaCargo(cargo);
    return rolesPermitidos.contains(rol);
  }
}
