import 'package:proyecto/features/auth/domain/entities/usuario.dart';
import 'package:proyecto/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  Future<Usuario> execute(String rut, String password) async {
    return await authRepository.login(rut, password);
  }

  Future<void> executeRegister(String rut, String password, String nombreCompleto) async {
    return await authRepository.registrarUsuario(rut, password, nombreCompleto);
  }
}