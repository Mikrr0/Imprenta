import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/core/models/perfil_trabajador.dart';

class PersonalViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<PerfilTrabajador> listaTrabajadores = [];
  bool estaCargando = false;

  Future<void> cargarTrabajadores() async {
    estaCargando = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('usuarios').get();
      
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
    } catch (e) {
      print("Error al cargar trabajadores: $e");
    }

    estaCargando = false;
    notifyListeners();
  }

  Future<bool> eliminarTrabajador(String idDoc) async {
    try {
      await _firestore.collection('usuarios').doc(idDoc).delete();
      listaTrabajadores.removeWhere((t) => t.id == idDoc);
      notifyListeners();
      return true;
    } catch (e) {
      print("Error al eliminar: $e");
      return false;
    }
  }
  // 3. ACTUALIZAR TRABAJADOR (EDITAR)
  Future<bool> actualizarTrabajador(String idDoc, Map<String, dynamic> nuevosDatos) async {
    try {
      // Actualizamos los datos en Firebase
      await _firestore.collection('usuarios').doc(idDoc).update(nuevosDatos);
      
      // Volvemos a descargar la lista para que la pantalla se actualice al instante
      await cargarTrabajadores(); 
      return true;
    } catch (e) {
      print("Error al actualizar: $e");
      return false;
    }
  }
}