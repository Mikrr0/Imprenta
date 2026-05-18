import 'package:proyecto/core/models/perfil_trabajador.dart';

abstract class AuthRepository {
  // Cambiado a PerfilTrabajador
  Future<PerfilTrabajador> login(String rut, String password);
  
  Future<void> registrarUsuario({
    required String rut, 
    required String password, 
    required String nombreCompleto,
    required String rol,
    required bool estado,
  });
  
  Future<void> logout();
  // Cambiado a PerfilTrabajador
  Stream<PerfilTrabajador> obtenerUsuarioStream(String uid);
}