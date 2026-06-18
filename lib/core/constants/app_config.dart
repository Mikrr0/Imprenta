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
  // [RF13] Roles de seguridad disponibles (solo 3)
  // Nota: Gerente es un CARGO bajo Administrador, no un rol
  // ═══════════════════════════════════════════════════════════════
  static const List<String> todosRoles = [
    'Operario',
    'Jefe',
    'Administrador',
  ];

  // ═══════════════════════════════════════════════════════════════
  // [RF2] [RF13] Mapeo: Cargo → Roles permitidos
  // Define qué roles pueden asignarse a cada cargo
  // ═══════════════════════════════════════════════════════════════
  static const Map<String, List<String>> cargoRolesMap = {
    'Operario de Impresión': ['Operario'],
    'Operario de Corte': ['Operario'],
    'Encargado de Bodega': ['Jefe'],
    'Jefe de Taller': ['Jefe'],
    'Administrador': ['Administrador'],
    'Gerente': ['Administrador'],
  };

  // ═══════════════════════════════════════════════════════════════
  // [RF2] [RF13] Mapeo INVERSO: Rol → Cargos permitidos
  // Define qué cargos pueden tener cada rol (validación bidireccional)
  // ═══════════════════════════════════════════════════════════════
  static const Map<String, List<String>> rolCargosMap = {
    'Operario': ['Operario de Impresión', 'Operario de Corte'],
    'Jefe': ['Jefe de Taller', 'Encargado de Bodega'],
    'Administrador': ['Administrador', 'Gerente'],
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

  /// [RF13] Obtiene los cargos permitidos para un rol específico (mapeo inverso)
  static List<String> getCargosParaRol(String rol) {
    return rolCargosMap[rol] ?? [];
  }

  /// Valida si un cargo existe en el sistema
  static bool cargoValido(String cargo) {
    return todosCargos.contains(cargo);
  }

  /// Valida si un rol existe en el sistema
  static bool rolValido(String rol) {
    return todosRoles.contains(rol);
  }

  /// Valida si la combinación cargo-rol es válida (bidireccional)
  /// ⚠️ SOLO para capas de AUTENTICACIÓN/REGISTRO - NO usar en UI
  static bool combinacionValida(String cargo, String rol) {
    final rolesPermitidos = getRolesParaCargo(cargo);
    final cargosPermitidos = getCargosParaRol(rol);
    
    // Valida en ambas direcciones: cargo→rol AND rol→cargo
    return rolesPermitidos.contains(rol) && cargosPermitidos.contains(cargo);
  }

  // ═══════════════════════════════════════════════════════════════
  // [RF2] [RF14] [RNF3] [RNF9] Matriz de Permisos - Renderizado de UI
  // Métodos semánticos para mostrar/ocultar módulos en Dashboard
  // ✓ Administrador tiene VISIBILIDAD de supervisión sobre todo
  // ✓ Pero solo puede EDITAR en su módulo específico (Administrador+Administrador)
  // ═══════════════════════════════════════════════════════════════

  /// [RF14-a] [HU12] Gestión de Trabajadores / Perfiles (STRICT: Solo Admin+Administrador)
  /// Módulo de TI/RRHH - crear, editar, auditar perfiles
  /// SOLO Administrador con cargo Administrador puede ENTRAR
  static bool puedeGestionarTrabajadores(String rol, String cargo) {
    return rol == 'Administrador' && cargo == 'Administrador';
  }

  /// [RF9] [RF11] [HU14] Reportes Analíticos
  /// Cualquier Administrador ve reportes (Gerente O Administrador)
  static bool puedeVerReportes(String rol, String cargo) {
    // Solo Administrador con cualquier cargo jerárquico puede ver reportes
    return rol == 'Administrador' && 
           (cargo == 'Gerente' || cargo == 'Administrador');
  }

  /// [HU01] [RF4] Órdenes de Producción
  /// Jefe de Taller supervisa + Administrador para auditoría + Operarios ven sus tareas
  static bool puedeVerOrdenesDeProduccion(String rol, String cargo) {
    // Jefe de Taller: supervisor operativo
    if (rol == 'Jefe' && cargo == 'Jefe de Taller') return true;
    
    // Administrador: auditoría y supervisión general
    if (rol == 'Administrador') return true;

    // Operarios: ven sus tareas asignadas
    if (rol == 'Operario' && 
        (cargo == 'Operario de Impresión' || cargo == 'Operario de Corte')) {
      return true;
    }
    
    return false;
  }

  /// [HU03] [HU09] [RF7] Gestión de Inventario / Insumos
  /// Encargado de Bodega ejecuta + Administrador para supervisión
  static bool puedeGestionarInventario(String rol, String cargo) {
    // Encargado de Bodega: gestión de stock
    if (rol == 'Jefe' && cargo == 'Encargado de Bodega') return true;
    
    // Administrador: supervisión y auditoría del catálogo
    if (rol == 'Administrador') return true;
    
    return false;
  }
}
