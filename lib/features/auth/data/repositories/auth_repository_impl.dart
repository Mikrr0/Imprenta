import 'package:proyecto/core/models/perfil_trabajador.dart';
import 'package:proyecto/features/auth/domain/repositories/auth_repository.dart';
import 'package:proyecto/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PerfilTrabajador> login(String rut, String password) async {
    return await remoteDataSource.login(rut, password);
  }

  @override
  Future<void> registrarUsuario({
    required PerfilTrabajador perfil,
    required String password, 
    required bool estado,
  }) async {
    return await remoteDataSource.registrarUsuario(
      perfil: perfil,
      password: password,
      estado: estado,
    );
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Stream<PerfilTrabajador> obtenerUsuarioStream(String uid) {
    return remoteDataSource.obtenerUsuarioStream(uid);
  }
}