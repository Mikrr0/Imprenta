// Archivo: lib/features/insumos/presentation/viewmodels/insumo_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proyecto/core/models/insumo.dart';
import '../../domain/usecases/insumos_usecase.dart';

class InsumoViewModel extends ChangeNotifier {
  final InsumosUseCase useCase;

  // --- ESTADOS DEL CATÁLOGO ---
  List<Insumo> listaInsumos = [];
  bool estaCargando = false;
  String? mensajeDeErrorVisible;
  StreamSubscription? _insumosSubscription;

  // --- ESTADOS DE CONFIGURACIÓN DINÁMICA ---
  List<String> tiposPapel = [];
  List<String> gramajes = [];
  List<String> tamanos = [];
  bool estaCargandoParametros = false;

  InsumoViewModel({required this.useCase});

  void limpiarError() {
    if (mensajeDeErrorVisible != null) {
      mensajeDeErrorVisible = null;
      notifyListeners();
    }
  }

  // NUEVO: Descarga las opciones para los menús desplegables
  Future<void> cargarParametros() async {
    estaCargandoParametros = true;
    notifyListeners();

    try {
      final parametros = await useCase.obtenerParametrosConfiguracion();
      tiposPapel = parametros['tiposPapel'] ?? [];
      gramajes = parametros['gramajes'] ?? [];
      tamanos = parametros['tamanos'] ?? [];
    } catch (e) {
      mensajeDeErrorVisible = "Error al cargar opciones de configuración.";
    } finally {
      estaCargandoParametros = false;
      notifyListeners();
    }
  }

  void iniciarEscuchaInsumos() {
    estaCargando = true;
    notifyListeners();

    _insumosSubscription?.cancel();

    _insumosSubscription = useCase.obtenerInsumos().listen((insumos) {
      listaInsumos = insumos;
      estaCargando = false;
      notifyListeners();
    }, onError: (error) {
      estaCargando = false;
      mensajeDeErrorVisible = "Error al cargar el inventario. Revise su conexión.";
      notifyListeners();
    });
  }

  Future<bool> guardarInsumo({
    String? id,
    required String nombre,
    required String tipoPapel,
    required String gramaje,
    required String tamano,
    required String stockStr,
    required String precioStr,
  }) async {
    estaCargando = true;
    mensajeDeErrorVisible = null;
    notifyListeners();

    try {
      final int stock = int.tryParse(stockStr.trim()) ?? -1;
      final double precio = double.tryParse(precioStr.trim()) ?? -1.0;

      if (stock < 0 || precio < 0) {
        throw Exception("Stock y precio deben ser números válidos y positivos.");
      }
      
      if (nombre.trim().isEmpty) {
         throw Exception("El nombre del insumo no puede estar vacío.");
      }

      final insumo = Insumo(
        id: id,
        nombre: nombre.trim(),
        tipoPapel: tipoPapel,
        gramaje: gramaje,
        tamano: tamano,
        stock: stock,
        precioUnitario: precio,
      );

      if (id == null) {
        await useCase.crearInsumo(insumo);
      } else {
        await useCase.actualizarInsumo(insumo);
      }

      estaCargando = false;
      notifyListeners();
      return true;

    } catch (e) {
      estaCargando = false;
      mensajeDeErrorVisible = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarInsumo(String id) async {
    try {
      await useCase.eliminarInsumo(id);
      return true;
    } catch (e) {
      mensajeDeErrorVisible = "Error al eliminar el insumo.";
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _insumosSubscription?.cancel();
    super.dispose();
  }
}