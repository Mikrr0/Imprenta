// Archivo: lib/features/insumos/domain/repositories/insumos_repository.dart
import 'package:proyecto/core/models/insumo.dart';

abstract class InsumosRepository {
  // CRUD del Catálogo
  Stream<List<Insumo>> obtenerInsumosStream();
  Future<void> crearInsumo(Insumo insumo);
  Future<void> actualizarInsumo(Insumo insumo);
  Future<void> eliminarInsumo(String id);

  // NUEVO: Obtener las listas dinámicas de configuración (RF7)
  Future<Map<String, List<String>>> obtenerParametrosConfiguracion();
}