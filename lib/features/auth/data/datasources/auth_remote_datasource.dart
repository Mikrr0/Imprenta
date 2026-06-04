import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/core/models/perfil_trabajador.dart'; 

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

  /// Generador del correo falso para engañar a Firebase Auth
  String _rutAEmail(String rut) {
    String rutLimpio = rut.replaceAll('-', '').replaceAll('.', '');
    return "$rutLimpio@imprenta.cl";
  }

  @override
  Future<PerfilTrabajador> login(String rut, String password) async {
    try {
      // Usamos DIRECTAMENTE el correo falso basado en el RUT
      final String emailFalsoAuth = _rutAEmail(rut);
      
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: emailFalsoAuth,
        password: password,
      );

      final String uid = userCredential.user!.uid;
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        
        // --- NUEVO CANDADO DE SEGURIDAD ---
        // Revisamos si el usuario fue inhabilitado (Soft Delete)
        if (data['estado'] == false) {
          await _firebaseAuth.signOut(); // Lo expulsamos de Auth por si acaso
          throw Exception("CUENTA_INHABILITADA");
        }

        return PerfilTrabajador(
          rut: rut,
          nombreCompleto: data['nombreCompleto'],
          correoElectronico: data['correoElectronico'], // Aquí baja el correo real de la BD
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
      
      // --- NUEVO CANDADO REACTIVO ---
      // Si le cambian el estado a false mientras está usando la app, el Stream lanza el error
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
    try {
      // 1. Definimos las dos identidades separadas
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

      // 2. Engañamos a Firebase Auth registrándolo con el RUT (Email falso)
      final credential = await authTemporal.createUserWithEmailAndPassword(
        email: emailFalsoParaAuth, 
        password: password,
      );

      final String uidGenerado = credential.user!.uid;
      
      // 3. Guardamos en Firestore los datos limpios incluyendo el correo real
      final Map<String, dynamic> datosUsuario = perfil.toMap();
      datosUsuario['id'] = uidGenerado;
      datosUsuario['estado'] = estado; // Se guarda como true al crearlo
      datosUsuario['correoElectronico'] = emailRealParaBD;

      await _firestore.collection('usuarios').doc(uidGenerado).set(datosUsuario);
    } catch (e) {
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