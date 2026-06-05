import 'package:proyecto/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:proyecto/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:proyecto/features/auth/domain/usecases/login_usecase.dart';
import 'package:proyecto/features/auth/presentation/viewmodels/login_viewmodel.dart';

// --- NUEVOS IMPORTS PARA INSUMOS ---
import 'package:proyecto/features/insumos/data/datasources/insumos_remote_datasource.dart';
import 'package:proyecto/features/insumos/data/repositories/insumos_repository_impl.dart';
import 'package:proyecto/features/insumos/domain/usecases/insumos_usecase.dart';
import 'package:proyecto/features/insumos/presentation/viewmodels/insumo_viewmodel.dart';

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

  // --- NUEVO MÉTODO PARA INYECTAR INSUMOS ---
  static InsumoViewModel buildInsumoViewModel() {
    // 1. Creamos la conexión a la base de datos de Firebase para Insumos
    final dataSource = InsumosRemoteDataSourceImpl();
    
    // 2. Le pasamos la conexión al repositorio
    final repository = InsumosRepositoryImpl(remoteDataSource: dataSource);
    
    // 3. Le pasamos el repositorio al caso de uso (donde están las reglas de negocio)
    final useCase = InsumosUseCase(repository);
    
    // 4. Inyectamos el caso de uso en el ViewModel de Insumos
    return InsumoViewModel(useCase: useCase);
  }
}