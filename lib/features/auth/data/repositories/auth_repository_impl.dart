import 'package:proyecto/features/auth/domain/entities/usuario.dart';
import 'package:proyecto/features/auth/domain/repositories/auth_repository.dart';
import 'package:proyecto/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Usuario> login(String rut, String password) async {
    return await remoteDataSource.login(rut, password);
  }

   @override
  Future<void> registrarUsuario(String rut, String password, String nombreCompleto) async {

  return await remoteDataSource.registrarUsuario(rut, password, nombreCompleto);
}

  @override
  Future<void> logout() async {
    return await remoteDataSource.logout();
  }

  @override
  Stream<Usuario> obtenerUsuarioStream(String uid) {
    return remoteDataSource.obtenerUsuarioStream(uid);
  }
}