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

  String _rutAEmail(String rut) {
    String rutLimpio = rut.replaceAll('-', '').replaceAll('.', '');
    return "$rutLimpio@imprenta.cl";
  }

  @override
  Future<PerfilTrabajador> login(String rut, String password) async {
    try {
      final String emailFalsoAuth = _rutAEmail(rut);
      
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: emailFalsoAuth,
        password: password,
      );

      final String uid = userCredential.user!.uid;
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        
        // Candado de Borrado Lógico
        if (data['estado'] == false) {
          await _firebaseAuth.signOut();
          throw Exception("CUENTA_INHABILITADA");
        }

        return PerfilTrabajador(
          rut: rut,
          nombreCompleto: data['nombreCompleto'],
          correoElectronico: data['correoElectronico'], 
          cargo: data['cargo'],
          rol: data['rol'],
          sueldoBase: (data['sueldoBase'] as num).toDouble(),
        );
      } else {
        throw Exception("Falta el documento en la base de datos");
      }
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
    auth.UserCredential? credential; // Lógica de Rollback de Alejandro
    
    try {
      final String emailFalsoParaAuth = _rutAEmail(perfil.rut);
      final String emailRealParaBD = perfil.correoElectronico.isNotEmpty
          ? perfil.correoElectronico
          : emailFalsoParaAuth;

      appTemporal = await Firebase.initializeApp(
        name: _userCreationBridgeAppName,
        options: Firebase.app().options,
      );

      final auth.FirebaseAuth authTemporal = auth.FirebaseAuth.instanceFor(
        app: appTemporal,
      );

      // Creamos la cuenta en el puente temporal
      credential = await authTemporal.createUserWithEmailAndPassword(
        email: emailFalsoParaAuth, 
        password: password,
      );

      final String uidGenerado = credential.user!.uid;
      
      // Guardamos en Firestore los datos
      final Map<String, dynamic> datosUsuario = perfil.toMap();
      datosUsuario['id'] = uidGenerado;
      datosUsuario['estado'] = estado; 
      datosUsuario['correoElectronico'] = emailRealParaBD;

      await _firestore.collection('usuarios').doc(uidGenerado).set(datosUsuario);
      
    } catch (e) {
      // ROLLBACK DE ALEJANDRO: Si Firestore falla, eliminamos de Auth
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