import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/notificacion_interna.dart';

class NotificacionViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _notificacionesSub;
  
  List<NotificacionInterna> _notificaciones = [];
  List<NotificacionInterna> get notificaciones => _notificaciones;

  int get unreadCount => _notificaciones.where((n) => !n.leida).length;

  void iniciarEscucha(String userRole) {
    _notificacionesSub?.cancel();

    // Solo escuchamos si es Jefe o Admin
    if (userRole != 'Jefe' && userRole != 'Administrador') {
      _notificaciones = [];
      notifyListeners();
      return;
    }

    _notificacionesSub = _firestore
        .collection('notificaciones_internas')
        .where('destinatarios', arrayContains: userRole)
        .snapshots()
        .listen((snapshot) {
      
      final ahora = DateTime.now();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day); // 00:00:00 de hoy

      final List<NotificacionInterna> nuevasNotificaciones = [];

      for (var doc in snapshot.docs) {
        final notificacion = NotificacionInterna.fromFirestore(doc);
        
        final fechaNoti = DateTime(
          notificacion.fechaHora.year,
          notificacion.fechaHora.month,
          notificacion.fechaHora.day,
        );

        // CONDICIÓN: Mostrar en la campanita SOLO si la notificación es de la jornada de hoy.
        // Las antiguas se ignoran en esta lista visual, pero quedan guardadas en Firebase como registro histórico.
        if (!fechaNoti.isBefore(hoy)) {
          // Si es de hoy, la agregamos a la lista visual
          nuevasNotificaciones.add(notificacion);
        }
      }

      // Ordenar las más recientes primero
      nuevasNotificaciones.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
      
      _notificaciones = nuevasNotificaciones;
      notifyListeners();
    });
  }

  Future<void> marcarComoLeida(String id) async {
    try {
      await _firestore.collection('notificaciones_internas').doc(id).update({
        'leida': true,
      });
    } catch (e) {
      debugPrint("Error al marcar como leída: $e");
    }
  }

  @override
  void dispose() {
    _notificacionesSub?.cancel();
    super.dispose();
  }
}
