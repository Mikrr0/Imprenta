import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/core/models/perfil_trabajador.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<PerfilTrabajador> listaTrabajadores = [];
  bool estaCargando = false;
  
  StreamSubscription<QuerySnapshot>? _trabajadoresSubscription;

  void iniciarEscuchaTrabajadores() {
    estaCargando = true;
    notifyListeners();

    _trabajadoresSubscription?.cancel();

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
      debugPrint("Error al cargar trabajadores: $error");
      estaCargando = false;
      notifyListeners();
    });
  }

  Future<bool> eliminarTrabajador(String idDoc) async {
    try {
      await _firestore.collection('usuarios').doc(idDoc).update({'estado': false});
      return true;
    } catch (e) {
      debugPrint("Error al inhabilitar: $e");
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

  @override
  void dispose() {
    _trabajadoresSubscription?.cancel();
    super.dispose();
  }
}