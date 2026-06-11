import 'package:cloud_firestore/cloud_firestore.dart';

class OrdenTrabajo {
  final String id;
  final String descripcion;
  final DateTime fechaCreacion;
  final DateTime fechaEntrega;
  final String prioridad; // 'Baja', 'Media', 'Alta'
  final String operarioId; // UID del operario asignado
  final String estado; // 'Pendiente', 'En Proceso', 'Detenida', 'Finalizada'
  final int version; // CRÍTICO: Para el Bloqueo Optimista

  OrdenTrabajo({
    required this.id,
    required this.descripcion,
    required this.fechaCreacion,
    required this.fechaEntrega,
    required this.prioridad,
    required this.operarioId,
    required this.estado,
    required this.version,
  });

  // Convertir de Firestore a objeto Dart
  factory OrdenTrabajo.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrdenTrabajo(
      id: doc.id,
      descripcion: data['descripcion'] ?? '',
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
      fechaEntrega: (data['fechaEntrega'] as Timestamp).toDate(),
      prioridad: data['prioridad'] ?? 'Baja',
      operarioId: data['operarioId'] ?? '',
      estado: data['estado'] ?? 'Pendiente',
      version: data['version'] ?? 1,
    );
  }

  // Convertir de objeto Dart a Map para enviar a Firestore
  Map<String, dynamic> toMap() {
    return {
      'descripcion': descripcion,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaEntrega': Timestamp.fromDate(fechaEntrega),
      'prioridad': prioridad,
      'operarioId': operarioId,
      'estado': estado,
      'version': version,
    };
  }
}