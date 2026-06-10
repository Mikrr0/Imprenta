import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/asistencia.dart';

class AsistenciaViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // El estado global ahora vive aquí y no se borra al cambiar de pantalla
  bool estadoAsistenciaActiva = false;
  int segundosRestantesParaMarcar = 0;
  Timer? _temporizadorMarcaje;

  bool get puedeMarcarAsistencia => segundosRestantesParaMarcar == 0;

  Future<bool> registrarAsistencia(String uid) async {
    if (!puedeMarcarAsistencia) return false;

    // Determina si es Entrada o Salida según el estado actual
    final tipoMarca = estadoAsistenciaActiva ? "Salida" : "Entrada";

    try {
      final nuevaAsistencia = Asistencia(
        uidTrabajador: uid,
        tipo: tipoMarca,
        fechaHora: DateTime.now(),
      );

      // Guarda en Firestore
      await _firestore.collection('asistencia').add(nuevaAsistencia.toMap());

      // Si tiene éxito, cambiamos el estado e iniciamos el bloqueo de 2 minutos
      estadoAsistenciaActiva = !estadoAsistenciaActiva;
      segundosRestantesParaMarcar = 120;
      notifyListeners();

      _iniciarTemporizador();
      return true;
    } catch (e) {
      debugPrint("Error al registrar asistencia: $e");
      return false;
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
