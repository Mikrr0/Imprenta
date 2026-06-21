import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/core/models/perfil_trabajador.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<PerfilTrabajador> listaTrabajadores = [];
  List<PerfilTrabajador> listaTrabajadoresInactivos = []; // <-- Nueva lista para los inhabilitados
  bool estaCargando = false;
  
  StreamSubscription<QuerySnapshot>? _trabajadoresSubscription;

  void iniciarEscuchaTrabajadores() {
    estaCargando = true;
    notifyListeners();

    _trabajadoresSubscription?.cancel();

    // Escuchamos la colección completa para clasificar en tiempo real
    _trabajadoresSubscription = _firestore
        .collection('usuarios')
        .snapshots()
        .listen((snapshot) {
      
      final List<PerfilTrabajador> activos = [];
      final List<PerfilTrabajador> inactivos = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final bool esActivo = data['estado'] ?? true;

        final trabajador = PerfilTrabajador(
          id: doc.id,
          rut: data['rut'] ?? '',
          nombreCompleto: data['nombreCompleto'] ?? data['nombre'] ?? 'Sin nombre',
          correoElectronico: data['correoElectronico'] ?? '',
          cargo: data['cargo'] ?? 'Sin cargo',
          rol: data['rol'] ?? 'Sin rol',
          sueldoBase: (data['sueldoBase'] ?? 0).toDouble(),
        );

        if (esActivo) {
          activos.add(trabajador);
        } else {
          inactivos.add(trabajador);
        }
      }

      listaTrabajadores = activos;
      listaTrabajadoresInactivos = inactivos; // <-- Se actualiza la lista de dados de baja

      estaCargando = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint("Error al cargar trabajadores: $error");
      estaCargando = false;
      notifyListeners();
    });
  }

 Future<bool> eliminarTrabajador(String idDoc) async {
    try {
      await _firestore.collection('usuarios').doc(idDoc).update({'estado': false});
      
      final adminUid = FirebaseAuth.instance.currentUser?.uid ?? 'Usuario_Desconocido';
      
      // --- Esto es para saber quien hizo la acción y quien la recibio y no salga la id y sea mas claro ---
      String nombreAdmin = "Admin Desconocido";
      String nombreTrabajador = "Trabajador Desconocido";

      if (adminUid != 'Usuario_Desconocido') {
        final adminSnapshot = await _firestore.collection('usuarios').doc(adminUid).get();
        nombreAdmin = adminSnapshot.data()?['nombreCompleto'] ?? adminSnapshot.data()?['nombre'] ?? 'Admin';
      }
      
      final trabajadorSnapshot = await _firestore.collection('usuarios').doc(idDoc).get();
      nombreTrabajador = trabajadorSnapshot.data()?['nombreCompleto'] ?? trabajadorSnapshot.data()?['nombre'] ?? 'Trabajador';
      // ------------------------------------------------

      await _firestore.collection('logs_auditoria').add({
        'uid_administrador_operador': adminUid,
        'nombre_administrador': nombreAdmin, 
        'id_usuario_modificado': idDoc,
        'nombre_usuario_modificado': nombreTrabajador,
        'fecha_hora': FieldValue.serverTimestamp(),
        'accion': 'INHABILITACION_USUARIO'
      });

      return true;
    } catch (e) {
      debugPrint("Error al inhabilitar: $e");
      return false;
    }
  }

  Future<bool> habilitarTrabajador(String idDoc) async {
    try {
      await _firestore.collection('usuarios').doc(idDoc).update({'estado': true});
      
      final adminUid = FirebaseAuth.instance.currentUser?.uid ?? 'Usuario_Desconocido';
      
      // --- Esto es para saber quien hizo la acción y quien la recibio y no salga la id y sea mas claro ---
      String nombreAdmin = "Admin Desconocido";
      String nombreTrabajador = "Trabajador Desconocido";

      if (adminUid != 'Usuario_Desconocido') {
        final adminSnapshot = await _firestore.collection('usuarios').doc(adminUid).get();
        nombreAdmin = adminSnapshot.data()?['nombreCompleto'] ?? adminSnapshot.data()?['nombre'] ?? 'Admin';
      }
      
      final trabajadorSnapshot = await _firestore.collection('usuarios').doc(idDoc).get();
      nombreTrabajador = trabajadorSnapshot.data()?['nombreCompleto'] ?? trabajadorSnapshot.data()?['nombre'] ?? 'Trabajador';
      await _firestore.collection('logs_auditoria').add({
        'uid_administrador_operador': adminUid,
        'nombre_administrador': nombreAdmin,
        'id_usuario_modificado': idDoc,
        'nombre_usuario_modificado': nombreTrabajador, 
        'fecha_hora': FieldValue.serverTimestamp(),
        'accion': 'HABILITACION_USUARIO' 
      });

      return true;
    } catch (e) {
      debugPrint("Error al habilitar: $e");
      return false;
    }
  }

  Future<bool> actualizarTrabajador(String idDoc, Map<String, dynamic> nuevosDatos) async {
    try {
      await _firestore.collection('usuarios').doc(idDoc).update(nuevosDatos);
      
      if (nuevosDatos.containsKey('rol')) {
        final adminUid = FirebaseAuth.instance.currentUser?.uid ?? 'Usuario_Desconocido';
        
        await _firestore.collection('logs_auditoria').add({
          'uid_administrador_operador': adminUid,
          'id_usuario_modificado': idDoc,
          'nuevo_rol_asignado': nuevosDatos['rol'],
          'fecha_hora': FieldValue.serverTimestamp(),
          'accion': 'MODIFICACION_PERMISOS'
        });
      }
      
      return true;
    } catch (e) {
      debugPrint("Error al actualizar: $e");
      return false;
    }
  }

  // NUEVO: Método para buscar un trabajador específico devolviendo el Modelo puro
  Future<PerfilTrabajador?> obtenerTrabajadorPorId(String idDoc) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(idDoc).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return PerfilTrabajador(
          id: doc.id,
          rut: data['rut'] ?? '',
          nombreCompleto: data['nombreCompleto'] ?? data['nombre'] ?? 'Sin nombre',
          correoElectronico: data['correoElectronico'] ?? '',
          cargo: data['cargo'] ?? 'Sin cargo',
          rol: data['rol'] ?? 'Sin rol',
          sueldoBase: (data['sueldoBase'] ?? 0).toDouble(),
        );
      }
    } catch (e) {
      debugPrint("Error al buscar trabajador por ID: $e");
    }
    return null;
  }

  @override
  void dispose() {
    _trabajadoresSubscription?.cancel();
    super.dispose();
  }
}