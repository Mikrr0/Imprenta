import 'package:proyecto/core/models/movimiento_bodega.dart';
import 'package:proyecto/core/models/proveedor.dart';

abstract class BodegaRepository {
  Stream<List<Proveedor>> obtenerProveedoresStream();
  Future<void> registrarProveedor(Proveedor proveedor);
  Future<void> registrarIngresoBodega(MovimientoBodega movimiento);
}