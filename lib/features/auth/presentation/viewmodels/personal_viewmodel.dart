import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/core/models/perfil_trabajador.dart';

class PersonalViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<PerfilTrabajador> listaTrabajadores = [];
  bool estaCargando = false;
  
  // Control de la escucha en vivo
  StreamSubscription<QuerySnapshot>? _trabajadoresSubscription;

  // Se cambia cargarTrabajadores() por un Stream reactivo
  void iniciarEscuchaTrabajadores() {
    estaCargando = true;
    notifyListeners();

    _trabajadoresSubscription?.cancel();

    // Filtramos directamente en la base de datos: solo traemos a los que tienen estado == true
    _trabajadoresSubscription = _firestore
        .collection('usuarios')
        .where('estado', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      
      listaTrabajadores = snapshot.docs.map((doc) {
        final data = doc.data();
        return PerfilTrabajador(
          id: doc.id,
          rut: data['rut'] ?? '',
          nombreCompleto: data['nombreCompleto'] ?? data['nombre'] ?? 'Sin nombre',
          correoElectronico: data['correoElectronico'] ?? '',
          cargo: data['cargo'] ?? 'Sin cargo',
          rol: data['rol'] ?? 'Sin rol',
          sueldoBase: (data['sueldoBase'] ?? 0).toDouble(),
        );
      }).toList();

      estaCargando = false;
      notifyListeners();
    }, onError: (error) {
      print("Error al cargar trabajadores: $error");
      estaCargando = false;
      notifyListeners();
    });
  }

  Future<bool> eliminarTrabajador(String idDoc) async {
    try {
      // BORRADO LÓGICO (Soft Delete): Cambiamos el estado en vez de destruir el documento
      await _firestore.collection('usuarios').doc(idDoc).update({'estado': false});
      // El Stream detecta el cambio automáticamente y actualiza la lista. No hace falta notifyListeners().
      return true;
    } catch (e) {
      print("Error al inhabilitar: $e");
      return false;
    }
  }

  // 3. ACTUALIZAR TRABAJADOR (EDITAR)
  Future<bool> actualizarTrabajador(String idDoc, Map<String, dynamic> nuevosDatos) async {
    try {
      await _firestore.collection('usuarios').doc(idDoc).update(nuevosDatos);
      // El Stream detecta el cambio automáticamente. Ya no hace falta recargar la lista manual.
      return true;
    } catch (e) {
      print("Error al actualizar: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _trabajadoresSubscription?.cancel();
    super.dispose();
  }
}