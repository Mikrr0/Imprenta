class Proveedor {
  final String? id;
  final String rut;
  final String nombreEmpresa;
  final String contacto;
  final bool estado; // Para borrado lógico (Soft Delete)

  Proveedor({
    this.id,
    required this.rut,
    required this.nombreEmpresa,
    required this.contacto,
    this.estado = true,
  });

  factory Proveedor.fromMap(Map<String, dynamic> data, String documentId) {
    return Proveedor(
      id: documentId,
      rut: data['rut'] ?? '',
      nombreEmpresa: data['nombreEmpresa'] ?? '',
      contacto: data['contacto'] ?? '',
      estado: data['estado'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rut': rut,
      'nombreEmpresa': nombreEmpresa,
      'contacto': contacto,
      'estado': estado,
    };
  }

  Proveedor copyWith({
    String? id,
    String? rut,
    String? nombreEmpresa,
    String? contacto,
    bool? estado,
  }) {
    return Proveedor(
      id: id ?? this.id,
      rut: rut ?? this.rut,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      contacto: contacto ?? this.contacto,
      estado: estado ?? this.estado,
    );
  }
}