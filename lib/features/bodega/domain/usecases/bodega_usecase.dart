import 'package:proyecto/core/models/movimiento_bodega.dart';
import 'package:proyecto/core/models/proveedor.dart';
import 'package:proyecto/features/bodega/domain/repositories/bodega_repository.dart';

class BodegaUseCase {
  final BodegaRepository repository;

  BodegaUseCase({required this.repository});

  Stream<List<Proveedor>> obtenerProveedores() {
    return repository.obtenerProveedoresStream();
  }

  Future<void> registrarProveedor(Proveedor proveedor) async {
    // Validaciones extra de negocio podrían ir aquí antes de llamar a BD
    await repository.registrarProveedor(proveedor);
  }

  Future<void> procesarIngresoBodega(MovimientoBodega movimiento) async {
    if (movimiento.cantidadIngresada <= 0) {
      throw Exception("La cantidad a ingresar debe ser mayor a cero.");
    }
    await repository.registrarIngresoBodega(movimiento);
  }
}