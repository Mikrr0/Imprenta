import 'package:proyecto/core/models/perfil_trabajador.dart';

abstract class AuthRepository {
  Future<PerfilTrabajador> login(String rut, String password);
  
  Future<void> registrarUsuario({
    required PerfilTrabajador perfil,
    required String password,
    required bool estado,
  });
  
  Future<void> logout();
  Stream<PerfilTrabajador> obtenerUsuarioStream(String uid);
}