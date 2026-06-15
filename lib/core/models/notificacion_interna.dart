import 'package:cloud_firestore/cloud_firestore.dart';

class NotificacionInterna {
  final String id;
  final String trabajadorId;
  final String nombreTrabajador;
  final DateTime fechaHora;
  final String tipoIncidencia; // "Atraso" o "Ausencia"
  final List<String> destinatarios;
  final bool leida;

  NotificacionInterna({
    required this.id,
    required this.trabajadorId,
    required this.nombreTrabajador,
    required this.fechaHora,
    required this.tipoIncidencia,
    required this.destinatarios,
    required this.leida,
  });

  factory NotificacionInterna.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificacionInterna(
      id: doc.id,
      trabajadorId: data['trabajadorId'] ?? '',
      nombreTrabajador: data['nombreTrabajador'] ?? '',
      fechaHora: (data['fechaHora'] as Timestamp).toDate(),
      tipoIncidencia: data['tipoIncidencia'] ?? '',
      destinatarios: List<String>.from(data['destinatarios'] ?? []),
      leida: data['leida'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trabajadorId': trabajadorId,
      'nombreTrabajador': nombreTrabajador,
      'fechaHora': Timestamp.fromDate(fechaHora),
      'tipoIncidencia': tipoIncidencia,
      'destinatarios': destinatarios,
      'leida': leida,
    };
  }
}
