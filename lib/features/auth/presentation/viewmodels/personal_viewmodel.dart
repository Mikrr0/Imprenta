import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/core/models/perfil_trabajador.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      // 1. Actualizamos los datos en Firebase (como lo hacíamos normalmente)
      await _firestore.collection('usuarios').doc(idDoc).update(nuevosDatos);
      
      // 2. [CRITERIO 3] LOG DE AUDITORÍA: Guardamos el registro si se modificó el rol
      if (nuevosDatos.containsKey('rol')) {
        // Obtenemos el UID del administrador que está usando la app en este momento
        final adminUid = FirebaseAuth.instance.currentUser?.uid ?? 'Usuario_Desconocido';
        
        // Creamos el registro en una nueva colección segura
        await _firestore.collection('logs_auditoria').add({
          'uid_administrador_operador': adminUid,
          'id_usuario_modificado': idDoc,
          'nuevo_rol_asignado': nuevosDatos['rol'],
          'fecha_hora': FieldValue.serverTimestamp(), // Usa la hora inalterable del servidor de Google
          'accion': 'MODIFICACION_PERMISOS'
        });
      }
      
      // 3. Volvemos a descargar la lista para actualizar la pantalla
      await cargarTrabajadores(); 
      return true;
    } catch (e) {
      print("Error al actualizar: $e");
      return false;
    }
  }
}