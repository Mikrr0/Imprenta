import 'package:proyecto/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:proyecto/features/auth/domain/usecases/login_usecase.dart';
import 'package:proyecto/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:proyecto/features/auth/data/datasources/auth_remote_datasource.dart';

class AppDependencies {
  static LoginViewModel buildLoginViewModel() {
    final remoteDataSource = AuthRemoteDataSourceImpl();
    final authRepository = AuthRepositoryImpl(remoteDataSource);
    final loginUseCase = LoginUseCase(authRepository);
    
    return LoginViewModel(loginUseCase);
  }
}