import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/core/models/perfil_trabajador.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
<<<<<<< HEAD
      await _firestore.collection('usuarios').doc(idDoc).update(nuevosDatos);
      // El Stream detecta el cambio automáticamente. Ya no hace falta recargar la lista manual.
=======
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
>>>>>>> alejandro
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