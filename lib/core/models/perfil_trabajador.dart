/// [RF2] [RF13] Modelo de datos para perfil de trabajador
/// Representa los datos capturados en el formulario de creación de perfil
class PerfilTrabajador {
  final String nombreCompleto;
  final String rut;
  final String correoElectronico;
  final String cargo;
  final String rol;
  final double sueldoBase;

  PerfilTrabajador({
    required this.nombreCompleto,
    required this.rut,
    required this.correoElectronico,
    required this.cargo,
    required this.rol,
    required this.sueldoBase,
  });

  /// Convierte el modelo a un mapa (útil para serialización)
  Map<String, dynamic> toMap() {
    return {
      'nombreCompleto': nombreCompleto,
      'rut': rut,
      'correoElectronico': correoElectronico,
      'cargo': cargo,
      'rol': rol,
      'sueldoBase': sueldoBase,
    };
  }

  /// Crea una representación legible del perfil para logs/auditoría
  String toLogString() {
    return 'Perfil(nombre=$nombreCompleto, rut=$rut, email=$correoElectronico, cargo=$cargo, rol=$rol, sueldo=$sueldoBase)';
  }

  @override
  String toString() => toLogString();
}
