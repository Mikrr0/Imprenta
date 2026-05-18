import 'package:proyecto/features/auth/domain/repositories/auth_repository.dart';
// Importamos el modelo correcto de Benjamín
import 'package:proyecto/core/models/perfil_trabajador.dart'; 

class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  // Ahora retorna un PerfilTrabajador
  Future<PerfilTrabajador> execute(String rut, String password) async {
    return await authRepository.login(rut, password);
  }

  Future<void> registrarNuevoUsuario({
    required String rut, 
    required String password, 
    required String nombre,
    required String rol,
    required bool estado,
  }) async {
    return await authRepository.registrarUsuario(
      rut: rut, 
      password: password, 
      nombreCompleto: nombre,
      rol: rol,
      estado: estado,
    );
  }
}