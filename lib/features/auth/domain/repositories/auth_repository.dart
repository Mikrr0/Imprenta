import 'package:proyecto/features/auth/domain/entities/usuario.dart';

abstract class AuthRepository {
  Future<Usuario> login(String rut, String password);
  Future<void> registrarUsuario(String rut, String password, String nombreCompleto);
  Future<void> logout();
  Stream<Usuario> obtenerUsuarioStream(String uid);
}