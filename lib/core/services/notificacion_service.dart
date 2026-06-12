import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notificacion_interna.dart';

class NotificacionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crea una notificación en la base de datos aplicando la estandarización requerida.
  Future<bool> _crearNotificacion(NotificacionInterna notificacion) async {
    // 1. VALIDACIÓN ESTRICTA (RF6)
    if (notificacion.tipoIncidencia != 'Atraso' && notificacion.tipoIncidencia != 'Ausencia') {
      throw Exception('Tipo de incidencia no permitido. Solo se acepta "Atraso" o "Ausencia".');
    }

    try {
      await _firestore.collection('notificaciones_internas').add(notificacion.toMap());
      return true;
    } catch (e) {
      print('Error al guardar notificación: $e');
      return false;
    }
  }

  /// Función específica solicitada para exponer a Front-End y registrar atrasos.
  Future<bool> crearAlertaAtraso(String trabajadorId, String nombreTrabajador) async {
    final nuevaNotificacion = NotificacionInterna(
      id: '', // Firestore generará el ID
      trabajadorId: trabajadorId,
      nombreTrabajador: nombreTrabajador,
      fechaHora: DateTime.now(),
      tipoIncidencia: 'Atraso', // Fijo según RF6
      destinatarios: ['Jefe', 'Administrador'], // Destinatarios obligatorios
      leida: false, // Estado inicial
    );

    return await _crearNotificacion(nuevaNotificacion);
  }

  /// Función específica para registrar ausencias (para uso futuro en scripts o cierres diarios).
  Future<bool> crearAlertaAusencia(String trabajadorId, String nombreTrabajador) async {
    final nuevaNotificacion = NotificacionInterna(
      id: '', 
      trabajadorId: trabajadorId,
      nombreTrabajador: nombreTrabajador,
      fechaHora: DateTime.now(),
      tipoIncidencia: 'Ausencia', // Fijo según RF6
      destinatarios: ['Jefe', 'Administrador'], 
      leida: false, 
    );

    return await _crearNotificacion(nuevaNotificacion);
  }
}
