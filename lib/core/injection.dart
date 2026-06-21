// Archivo: lib/core/injection.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto/core/theme/theme_provider.dart';

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

// --- NUEVOS IMPORTS PARA ÓRDENES DE TRABAJO ---
import 'package:proyecto/core/services/orden_trabajo_service.dart';
import 'package:proyecto/features/orden_trabajo/presentation/viewmodels/orden_trabajo_viewmodel.dart';

class AppDependencies {
  // Variable estática para guardar las preferencias en memoria
  static late SharedPreferences _prefs;

  // NUEVO: Inicializador asíncrono para dependencias pesadas
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // NUEVO: Inyector para el ThemeProvider
  static ThemeProvider buildThemeProvider() {
    return ThemeProvider(_prefs);
  }

  //nota: el orden es importante, primero se crea la conexion con firebase mediante el datasource, 
  //luego se inyecta ese datasource en el repositorio, luego el repositorio en el usecase
  // y finalmente el usecase en el viewmodel

  static LoginViewModel buildLoginViewModel() {
    final dataSource = AuthRemoteDataSourceImpl();
    final repository = AuthRepositoryImpl(remoteDataSource: dataSource);
    final loginUseCase = LoginUseCase(repository);
    return LoginViewModel(loginUseCase: loginUseCase);
  }

  static InsumoViewModel buildInsumoViewModel() {
    final dataSource = InsumosRemoteDataSourceImpl();
    final repository = InsumosRepositoryImpl(remoteDataSource: dataSource);
    final useCase = InsumosUseCase(repository);
    return InsumoViewModel(useCase: useCase);
  }

  static BodegaViewModel buildBodegaViewModel() {
    final dataSource = BodegaRemoteDataSourceImpl();
    final repository = BodegaRepositoryImpl(remoteDataSource: dataSource);
    final useCase = BodegaUseCase(repository: repository);
    return BodegaViewModel(useCase: useCase);
  }

  static OrdenTrabajoViewModel buildOrdenTrabajoViewModel() {
    final service = OrdenTrabajoService();
    return OrdenTrabajoViewModel(ordenTrabajoService: service);
  }
}