import 'package:proyecto/core/models/movimiento_bodega.dart';
import 'package:proyecto/core/models/proveedor.dart';
import 'package:proyecto/features/bodega/data/datasources/bodega_remote_datasource.dart';
import 'package:proyecto/features/bodega/domain/repositories/bodega_repository.dart';

class BodegaRepositoryImpl implements BodegaRepository {
  final BodegaRemoteDataSource remoteDataSource;

  BodegaRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<Proveedor>> obtenerProveedoresStream() {
    return remoteDataSource.obtenerProveedoresStream();
  }

  @override
  Future<void> registrarProveedor(Proveedor proveedor) async {
    await remoteDataSource.registrarProveedor(proveedor);
  }

  @override
  Future<void> registrarIngresoBodega(MovimientoBodega movimiento) async {
    await remoteDataSource.registrarIngresoBodega(movimiento);
  }
}