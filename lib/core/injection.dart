import 'package:proyecto/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:proyecto/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:proyecto/features/auth/domain/usecases/login_usecase.dart';
import 'package:proyecto/features/auth/presentation/viewmodels/login_viewmodel.dart';

class AppDependencies {
  static LoginViewModel buildLoginViewModel() {
    // 1. Creamos la conexión a la base de datos de Firebase
    final dataSource = AuthRemoteDataSourceImpl();
    
    // 2. Le pasamos la conexión al repositorio
   final repository = AuthRepositoryImpl(remoteDataSource: dataSource);
    // 3. Le pasamos el repositorio al caso de uso de Benjamín
    final loginUseCase = LoginUseCase(repository);
    
    // 4. Finalmente, inyectamos el caso de uso en tu ViewModel
    return LoginViewModel(loginUseCase: loginUseCase);
  }
}