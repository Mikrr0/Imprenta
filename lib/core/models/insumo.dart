// Modelo de datos para un insumo, el modelo cumple estrictamente con el RF7

class Insumo {
  final String? id;
  final String nombre;
  final String tipoPapel;
  final String gramaje;
  final String tamano;
  final int stock;
  final double precioUnitario;

  Insumo({
    this.id,
    required this.nombre,
    required this.tipoPapel,
    required this.gramaje,
    required this.tamano,
    required this.stock,
    required this.precioUnitario,
  });

  // Convierte el objeto a un Mapa para guardarlo en Firebase
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'tipoPapel': tipoPapel,
      'gramaje': gramaje,
      'tamano': tamano,
      'stock': stock,
      'precioUnitario': precioUnitario,
    };
  }

  // Crea un objeto Insumo a partir de los datos de Firebase
  factory Insumo.fromMap(Map<String, dynamic> map, String documentId) {
    return Insumo(
      id: documentId,
      nombre: map['nombre'] ?? '',
      tipoPapel: map['tipoPapel'] ?? '',
      gramaje: map['gramaje'] ?? '',
      tamano: map['tamano'] ?? '',
      stock: map['stock']?.toInt() ?? 0,
      precioUnitario: map['precioUnitario']?.toDouble() ?? 0.0,
    );
  }
}