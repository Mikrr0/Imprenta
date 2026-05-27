import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/core/models/perfil_trabajador.dart'; // <-- Cambiado el import

abstract class AuthRemoteDataSource {
  Future<PerfilTrabajador> login(String rut, String password);
  
  Future<void> registrarUsuario({
    required String rut, 
    required String password, 
    required String nombreCompleto,
    required String cargo,
    required String rol,
    required bool estado,
  });
  
  Future<void> logout();
  Stream<PerfilTrabajador> obtenerUsuarioStream(String uid);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _rutAEmail(String rut) {
    String rutLimpio = rut.replaceAll('-', '').replaceAll('.', '');
    return "$rutLimpio@imprenta.cl";
  }

  @override
  Future<PerfilTrabajador> login(String rut, String password) async {
    try {
      final String email = _rutAEmail(rut);
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user!.uid;
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        // Construimos el PerfilTrabajador con lo que venga de Firestore
        return PerfilTrabajador(
          rut: rut,
          nombreCompleto: data['nombre'] ?? data['nombreCompleto'] ?? 'Sin nombre',
          correoElectronico: email,
          cargo: data['cargo'] ?? 'Operario',
          rol: data['rol'] ?? 'trabajador',
          sueldoBase: (data['sueldoBase'] ?? 0).toDouble(),
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
      return PerfilTrabajador(
        rut: data['rut'] ?? '',
        nombreCompleto: data['nombre'] ?? data['nombreCompleto'] ?? 'Sin nombre',
        correoElectronico: _rutAEmail(data['rut'] ?? ''),
        cargo: data['cargo'] ?? 'Operario',
        rol: data['rol'] ?? 'trabajador',
        sueldoBase: (data['sueldoBase'] ?? 0).toDouble(),
      );
    });
  }

  @override
  Future<void> registrarUsuario({
    required String rut, 
    required String password, 
    required String nombreCompleto,
    required String cargo,
    required String rol,
    required bool estado,
  }) async {
    try {
      final String emailSimulado = _rutAEmail(rut);

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailSimulado, 
        password: password,
      );

      final String uidGenerado = credential.user!.uid;

      // [BUG-04] Guardamos cargo real (no "Por asignar"), rol y demás información
      await _firestore.collection('usuarios').doc(uidGenerado).set({
        'id': uidGenerado,
        'rut': rut,
        'nombreCompleto': nombreCompleto,
        'correoElectronico': emailSimulado,
        'cargo': cargo,
        'rol': rol,
        'sueldoBase': 0,
        'estado': estado,
      });
    } catch (e) {
      throw Exception("ERROR_REGISTRO_FIREBASE: ${e.toString()}");
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}