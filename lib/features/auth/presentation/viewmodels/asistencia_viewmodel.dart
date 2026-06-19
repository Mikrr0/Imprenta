import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/models/asistencia.dart';
import '../../../../core/services/notificacion_service.dart';

class AsistenciaViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool estadoAsistenciaActiva = false;
  int segundosRestantesParaMarcar = 0;
  Timer? _temporizadorMarcaje;
  bool _estaProcesando = false;

  String? _uidActual;

  bool get puedeMarcarAsistencia => segundosRestantesParaMarcar == 0;
  bool get estaProcesando => _estaProcesando;

  AsistenciaViewModel();

  Future<void> cargarEstado(String uid) async {
    if (_uidActual == uid) return;
    
    _uidActual = uid;
    _temporizadorMarcaje?.cancel();
    
    final prefs = await SharedPreferences.getInstance();
    estadoAsistenciaActiva = prefs.getBool('estadoAsistenciaActiva_$uid') ?? false;
    
    final ultimoMarcaje = prefs.getInt('ultimoMarcajeMillis_$uid') ?? 0;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final diferenciaEnSegundos = (ahora - ultimoMarcaje) ~/ 1000;
    
    if (ultimoMarcaje > 0 && diferenciaEnSegundos < 120) {
      segundosRestantesParaMarcar = 120 - diferenciaEnSegundos;
      _iniciarTemporizador();
    } else {
      segundosRestantesParaMarcar = 0;
    }
    notifyListeners();
  }

  Future<bool> registrarAsistencia(String uid, String nombre) async {
    if (!puedeMarcarAsistencia || _estaProcesando) return false;

    _estaProcesando = true;
    notifyListeners();

    // Determina si es Entrada o Salida según el estado actual
    final tipoMarca = estadoAsistenciaActiva ? "Salida" : "Entrada";

    try {
      await _firestore.collection('asistencia').add({
        'uid_trabajador': uid.isEmpty ? "RUT_O_ID_NO_ENCONTRADO" : uid,
        'nombre_trabajador': nombre,
        'tipo': tipoMarca,
        'fecha_hora': DateTime.now(),
      });

      // INTEGRACIÓN: Disparar alerta si es entrada y es más tarde de las 08:30 AM
      if (tipoMarca == "Entrada") {
        final horaActual = DateTime.now();
        if (horaActual.hour >= 8) {
          final notificacionService = NotificacionService();
          await notificacionService.crearAlertaAtraso(uid, nombre);
        }
      }

      estadoAsistenciaActiva = !estadoAsistenciaActiva;
      segundosRestantesParaMarcar = 120;
      
      // Guardar en persistencia con llave única por usuario
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('estadoAsistenciaActiva_$uid', estadoAsistenciaActiva);
      await prefs.setInt('ultimoMarcajeMillis_$uid', DateTime.now().millisecondsSinceEpoch);

      notifyListeners();

      _iniciarTemporizador();
      return true;
    } catch (e) {
      debugPrint("Error al registrar asistencia: $e");
      return false;
    } finally {
      _estaProcesando = false;
      notifyListeners();
    }
  }

  void _iniciarTemporizador() {
    _temporizadorMarcaje?.cancel();
    _temporizadorMarcaje = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (segundosRestantesParaMarcar <= 1) {
        timer.cancel();
        segundosRestantesParaMarcar = 0;
      } else {
        segundosRestantesParaMarcar--;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _temporizadorMarcaje?.cancel();
    super.dispose();
  }
}
