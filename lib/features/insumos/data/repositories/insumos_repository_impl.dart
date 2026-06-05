// Archivo: lib/features/insumos/data/repositories/insumos_repository_impl.dart
import 'package:proyecto/core/models/insumo.dart';
import '../../domain/repositories/insumos_repository.dart';
import '../datasources/insumos_remote_datasource.dart';

class InsumosRepositoryImpl implements InsumosRepository {
  final InsumosRemoteDataSource remoteDataSource;

  InsumosRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, List<String>>> obtenerParametrosConfiguracion() {
    return remoteDataSource.obtenerParametrosConfiguracion();
  }

  @override
  Stream<List<Insumo>> obtenerInsumosStream() {
    return remoteDataSource.obtenerInsumosStream();
  }

  @override
  Future<void> crearInsumo(Insumo insumo) {
    return remoteDataSource.crearInsumo(insumo);
  }

  @override
  Future<void> actualizarInsumo(Insumo insumo) {
    return remoteDataSource.actualizarInsumo(insumo);
  }

  @override
  Future<void> eliminarInsumo(String id) {
    return remoteDataSource.eliminarInsumo(id);
  }
}