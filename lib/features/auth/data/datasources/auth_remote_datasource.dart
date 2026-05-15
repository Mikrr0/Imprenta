import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/features/auth/domain/entities/usuario.dart';

abstract class AuthRemoteDataSource {
  Future<Usuario> login(String rut, String password);
  Future<void> registrarUsuario(String rut, String password, String nombreCompleto);
  Future<void> logout();
  
  Stream<Usuario> obtenerUsuarioStream(String uid);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _rutAEmail(String rut) {
    String rutLimpio = rut.replaceAll('-', '').replaceAll('.', '');
    return "$rutLimpio@imprenta.cl";
  }

  @override
  Future<Usuario> login(String rut, String password) async {
    try {
      final String email = _rutAEmail(rut);
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _firestore.collection('usuarios').doc(userCredential.user!.uid).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        return Usuario(
          rut: rut,
          nombre: data['nombre_completo'] ?? 'Sin nombre',
          rol: data['rol'] ?? 'Operario',
        );
      } else {
        throw Exception("Falta el documento en la base de datos");
      }
    } catch (e) {
      throw Exception("FIREBASE_ERROR: ${e.toString()}");
    }
  }

 
  @override
  Stream<Usuario> obtenerUsuarioStream(String uid) {
    
    return _firestore.collection('usuarios').doc(uid).snapshots().map((doc) {
      if (!doc.exists) throw Exception("Usuario no encontrado");
      
      final data = doc.data()!;
      return Usuario(
        rut: data['rut'] ?? '',
        nombre: data['nombre_completo'] ?? 'Sin nombre',
        rol: data['rol'] ?? 'Operario',
      );
    });
  }

  @override
  Future<void> registrarUsuario(String rut, String password, String nombreCompleto) async {
    try {
      final String email = _rutAEmail(rut);
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'rut': rut,
        'email_sistema': email,
        'nombre_completo': nombreCompleto,
        'rol': 'Administrador',
        'fecha_creacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error al registrar: ${e.toString()}");
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}