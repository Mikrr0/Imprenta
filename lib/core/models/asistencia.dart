import 'package:cloud_firestore/cloud_firestore.dart';

class Asistencia {
  final String uidTrabajador;
  final String tipo;
  final DateTime fechaHora;

  Asistencia({
    required this.uidTrabajador,
    required this.tipo,
    required this.fechaHora,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid_trabajador': uidTrabajador,
      'tipo': tipo,
      'fecha_hora': FieldValue.serverTimestamp(),
    };
  }
}
