// Archivo: lib/core/injection.dart
import 'package:proyecto/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:proyecto/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:proyecto/features/auth/domain/usecases/login_usecase.dart';
import 'package:proyecto/features/auth/presentation/viewmodels/login_viewmodel.dart';

// --- IMPORTS PARA INSUMOS ---
import 'package:proyecto/features/insumos/data/datasources/insumos_remote_datasource.dart';
import 'package:proyecto/features/insumos/data/repositories/insumos_repository_impl.dart';
import 'package:proyecto/features/insumos/domain/usecases/insumos_usecase.dart';
import 'package:proyecto/features/insumos/presentation/viewmodels/insumo_viewmodel.dart';

// --- NUEVOS IMPORTS PARA BODEGA ---
import 'package:proyecto/features/bodega/data/datasources/bodega_remote_datasource.dart';
import 'package:proyecto/features/bodega/data/repositories/bodega_repository_impl.dart';
import 'package:proyecto/features/bodega/domain/usecases/bodega_usecase.dart';
import 'package:proyecto/features/bodega/presentation/viewmodels/bodega_viewmodel.dart';

class AppDependencies {
  static LoginViewModel buildLoginViewModel() {
    // 1. Creamos la conexión a la base de datos de Firebase
    final dataSource = AuthRemoteDataSourceImpl();
    
    // 2. Le pasamos la conexión al repositorio
    final repository = AuthRepositoryImpl(remoteDataSource: dataSource);
    
    // 3. Le pasamos el repositorio al caso de uso
    final loginUseCase = LoginUseCase(repository);
    
    // 4. Finalmente, inyectamos el caso de uso en tu ViewModel
    return LoginViewModel(loginUseCase: loginUseCase);
  }

  // --- MÉTODO PARA INYECTAR INSUMOS ---
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

  // --- NUEVO MÉTODO PARA INYECTAR BODEGA ---
  static BodegaViewModel buildBodegaViewModel() {
    // 1. Creamos la conexión a la base de datos de Firebase para Bodega
    final dataSource = BodegaRemoteDataSourceImpl();
    
    // 2. Le pasamos la conexión al repositorio
    final repository = BodegaRepositoryImpl(remoteDataSource: dataSource);
    
    // 3. Le pasamos el repositorio al caso de uso
    final useCase = BodegaUseCase(repository: repository);
    
    // 4. Inyectamos el caso de uso en el ViewModel de Bodega
    return BodegaViewModel(useCase: useCase);
  }
}