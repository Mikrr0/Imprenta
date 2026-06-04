import 'package:proyecto/features/auth/domain/repositories/auth_repository.dart';
import 'package:proyecto/core/models/perfil_trabajador.dart'; 

class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  /// Ejecuta la autenticación inicial devolviendo el perfil del trabajador
  Future<PerfilTrabajador> execute(String rut, String password) async {
    return await authRepository.login(rut, password);
  }

  /// [RF2] [RF14] Transporta de forma limpia la entidad canónica hacia el repositorio
  /// Resguarda el sueldo base real y los metadatos capturados en el formulario
  Future<void> registrarUsuario({
    required PerfilTrabajador perfil,
    required String password,
    required bool estado,
  }) async {
    return await authRepository.registrarUsuario(
      perfil: perfil,
      password: password,
      estado: estado,
    );
  }
}