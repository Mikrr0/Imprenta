import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/core/models/perfil_trabajador.dart'; 
import 'package:flutter/foundation.dart';

abstract class AuthRemoteDataSource {
  Future<PerfilTrabajador> login(String rut, String password);
  
  Future<void> registrarUsuario({
    required PerfilTrabajador perfil,
    required String password, 
    required bool estado,
  });
  
  Future<void> logout();
  Stream<PerfilTrabajador> obtenerUsuarioStream(String uid);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _userCreationBridgeAppName = 'UserCreationBridge';

@override
  Future<PerfilTrabajador> login(String rut, String password) async {
    try {
      final String rutEscrito = rut.trim().toUpperCase(); // Ej: 21.080.616-4
      final String rutSinPuntos = rutEscrito.replaceAll('.', ''); // Ej: 21080616-4
      final String rutLimpioTotal = rutSinPuntos.replaceAll('-', ''); // Ej: 210806164

      final querySnapshot = await _firestore
          .collection('usuarios')
          .where('rut', whereIn: [rutEscrito, rutSinPuntos, rutLimpioTotal])
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("RUT no encontrado. Verifica los datos.");
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();

      if (data['estado'] == false) {
        throw Exception("CUENTA_INHABILITADA");
      }

      final String emailReal = data['correoElectronico'];


      await _firebaseAuth.signInWithEmailAndPassword(
        email: emailReal,
        password: password,
      );

      return PerfilTrabajador(
        rut: data['rut'],
        nombreCompleto: data['nombreCompleto'],
        correoElectronico: emailReal, 
        cargo: data['cargo'],
        rol: data['rol'],
        sueldoBase: (data['sueldoBase'] as num).toDouble(),
      );
    } catch (e) {
      throw Exception("FIREBASE_ERROR: ${e.toString()}");
    }
  }

  @override
  Stream<PerfilTrabajador> obtenerUsuarioStream(String uid) {
    return _firestore.collection('usuarios').doc(uid).snapshots().map((doc) {
      if (!doc.exists) throw Exception("Usuario no encontrado");
      
      final data = doc.data()!;
      
      if (data['estado'] == false) {
        throw Exception("CUENTA_INHABILITADA");
      }

      return PerfilTrabajador(
        rut: data['rut'] ?? '',
        nombreCompleto: data['nombreCompleto'],
        correoElectronico: data['correoElectronico'],
        cargo: data['cargo'],
        rol: data['rol'],
        sueldoBase: (data['sueldoBase'] as num).toDouble(),
      );
    });
  }

  @override
  Future<void> registrarUsuario({
    required PerfilTrabajador perfil,
    required String password, 
    required bool estado,
  }) async {
    FirebaseApp? appTemporal;
    auth.UserCredential? credential;
    
    try {

      final String emailRealParaAuthYBD = perfil.correoElectronico.trim();

      appTemporal = await Firebase.initializeApp(
        name: _userCreationBridgeAppName,
        options: Firebase.app().options,
      );

      final auth.FirebaseAuth authTemporal = auth.FirebaseAuth.instanceFor(
        app: appTemporal,
      );

      credential = await authTemporal.createUserWithEmailAndPassword(
        email: emailRealParaAuthYBD, 
        password: password,
      );

      final String uidGenerado = credential.user!.uid;
      
      final Map<String, dynamic> datosUsuario = perfil.toMap();
      datosUsuario['id'] = uidGenerado;
      datosUsuario['estado'] = estado; 
      datosUsuario['correoElectronico'] = emailRealParaAuthYBD;

      await _firestore.collection('usuarios').doc(uidGenerado).set(datosUsuario);
      
    } catch (e) {

      if (credential != null && credential.user != null) {
        try {
          await credential.user!.delete();
          debugPrint("Rollback exitoso: Usuario eliminado de Auth por fallo en Firestore.");
        } catch (rollbackError) {
          debugPrint("Error crítico en Rollback: $rollbackError");
        }
      }
      throw Exception("ERROR_REGISTRO_FIREBASE: ${e.toString()}");
    } finally {
      if (appTemporal != null) {
        try {
          final auth.FirebaseAuth authTemporal = auth.FirebaseAuth.instanceFor(app: appTemporal);
          await authTemporal.signOut();
        } catch (_) {}
        try {
          await appTemporal.delete();
        } catch (_) {}
      }
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}