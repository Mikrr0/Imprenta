// Archivo: lib/features/insumos/domain/usecases/insumos_usecase.dart
import 'package:proyecto/core/models/insumo.dart';
import '../repositories/insumos_repository.dart';

class InsumosUseCase {
  final InsumosRepository repository;

  InsumosUseCase(this.repository);

  // --- GESTIÓN DE CONFIGURACIONES ---
  Future<Map<String, List<String>>> obtenerParametrosConfiguracion() async {
    return await repository.obtenerParametrosConfiguracion();
  }

  // --- GESTIÓN DEL CATÁLOGO ---
  Stream<List<Insumo>> obtenerInsumos() {
    return repository.obtenerInsumosStream();
  }

  Future<void> crearInsumo(Insumo insumo) async {
    if (insumo.stock < 0 || insumo.precioUnitario < 0) {
      throw Exception("El stock y el precio unitario deben ser valores numéricos positivos.");
    }
    await repository.crearInsumo(insumo);
  }

  Future<void> actualizarInsumo(Insumo insumo) async {
    if (insumo.stock < 0 || insumo.precioUnitario < 0) {
      throw Exception("El stock y el precio unitario deben ser valores numéricos positivos.");
    }
    await repository.actualizarInsumo(insumo);
  }

  Future<void> eliminarInsumo(String id) async {
    await repository.eliminarInsumo(id);
  }
}