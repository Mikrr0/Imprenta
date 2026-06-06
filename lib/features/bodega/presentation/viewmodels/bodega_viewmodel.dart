// Archivo: lib/features/bodega/presentation/viewmodels/bodega_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:proyecto/core/models/movimiento_bodega.dart';
import 'package:proyecto/core/models/proveedor.dart';
import 'package:proyecto/features/bodega/domain/usecases/bodega_usecase.dart';

class BodegaViewModel extends ChangeNotifier {
  final BodegaUseCase useCase;

  BodegaViewModel({required this.useCase});

  // --- ESTADOS GLOBALES ---
  bool _estaCargando = false;
  bool get estaCargando => _estaCargando;

  String? _mensajeError;
  String? get mensajeError => _mensajeError;

  // --- STREAM DE PROVEEDORES ---
  // Ideal para popular los menús desplegables o la lista de la pantalla de proveedores en tiempo real
  Stream<List<Proveedor>> get proveedoresStream => useCase.obtenerProveedores();

  // --- CONTROL DE ESTADO ---
  void _setLoading(bool value) {
    _estaCargando = value;
    notifyListeners();
  }

  void limpiarError() {
    _mensajeError = null;
    notifyListeners();
  }

  // --- LÓGICA DE NEGOCIO ---

  /// Registra un nuevo proveedor en la base de datos
  Future<bool> registrarProveedor({
    required String rut,
    required String nombreEmpresa,
    required String contacto,
  }) async {
    _setLoading(true);
    _mensajeError = null;

    try {
      final nuevoProveedor = Proveedor(
        rut: rut,
        nombreEmpresa: nombreEmpresa,
        contacto: contacto,
      );

      await useCase.registrarProveedor(nuevoProveedor);
      _setLoading(false);
      return true;
    } catch (e) {
      _mensajeError = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Registra el ingreso de un camión a bodega y actualiza el stock automáticamente (HU03)
  Future<bool> registrarIngreso({
    required String insumoId,
    required String proveedorId,
    required String cantidadStr,
    required String registradoPorUid, // ID del bodeguero que hace el registro
  }) async {
    _setLoading(true);
    _mensajeError = null;

    try {
      final cantidad = int.tryParse(cantidadStr);
      if (cantidad == null || cantidad <= 0) {
        throw Exception("La cantidad a ingresar debe ser un número mayor a cero.");
      }

      final movimiento = MovimientoBodega(
        insumoId: insumoId,
        proveedorId: proveedorId,
        cantidadIngresada: cantidad,
        fechaRegistro: DateTime.now(),
        registradoPorUid: registradoPorUid,
      );

      await useCase.procesarIngresoBodega(movimiento);
      _setLoading(false);
      return true;
    } catch (e) {
      _mensajeError = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }
}