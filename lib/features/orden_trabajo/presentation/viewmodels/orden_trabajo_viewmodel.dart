import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/core/models/orden_trabajo.dart';
import 'package:proyecto/core/services/orden_trabajo_service.dart';

class OrdenTrabajoViewModel extends ChangeNotifier {
  final OrdenTrabajoService ordenTrabajoService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- ESTADOS ---
  List<OrdenTrabajo> listaOrdenes = [];
  bool estaCargando = false;
  String? mensajeDeErrorVisible;
  String? mensajeDeExitoVisible;
  StreamSubscription? _ordenesSubscription;

  // --- ESTADO DE CAMBIO DE ESTADO Y CREACIÓN ---
  bool estaCambiandoEstado = false;
  bool estaCreando = false;
  OrdenTrabajo? ordenSeleccionada;

  // --- LISTA DE ESTADOS VÁLIDOS ---
  final List<String> estadosValidos = ['Pendiente', 'En Proceso', 'Detenida', 'Finalizada'];

  OrdenTrabajoViewModel({required this.ordenTrabajoService});

  void limpiarError() {
    if (mensajeDeErrorVisible != null) {
      mensajeDeErrorVisible = null;
      notifyListeners();
    }
  }

  void limpiarExito() {
    if (mensajeDeExitoVisible != null) {
      mensajeDeExitoVisible = null;
      notifyListeners();
    }
  }

  /// Inicia la escucha reactiva de órdenes desde Firestore
  void iniciarEscuchaOrdenes({String? usuarioUid, String? usuarioRol}) {
    estaCargando = true;
    notifyListeners();

    try {
      Query query = _firestore.collection('ordenes_trabajo');

      // Si es operario, solo ve las órdenes asignadas a él
      if (usuarioRol == 'Operario' && usuarioUid != null) {
        query = query.where('operarioId', isEqualTo: usuarioUid);
      }

      _ordenesSubscription = query.snapshots().listen(
            (snapshot) {
              listaOrdenes = snapshot.docs
                  .map((doc) => OrdenTrabajo.fromDocument(doc))
                  .toList();
              estaCargando = false;
              notifyListeners();
            },
            onError: (error) {
              mensajeDeErrorVisible = 'Error al cargar órdenes: $error';
              estaCargando = false;
              notifyListeners();
            },
          );
    } catch (e) {
      mensajeDeErrorVisible = 'Error inicializando escucha: $e';
      estaCargando = false;
      notifyListeners();
    }
  }

  /// Obtiene una orden específica por su ID
  Future<OrdenTrabajo?> obtenerOrdenPorId(String ordenId) async {
    try {
      final doc = await _firestore.collection('ordenes_trabajo').doc(ordenId).get();
      if (doc.exists) {
        return OrdenTrabajo.fromDocument(doc);
      }
    } catch (e) {
      mensajeDeErrorVisible = 'Error obteniendo orden: $e';
      notifyListeners();
    }
    return null;
  }

  /// Cambia el estado de una orden con bloqueo optimista
  Future<void> cambiarEstadoOrden({
    required String ordenId,
    required String nuevoEstado,
    required int versionLocal,
  }) async {
    estaCambiandoEstado = true;
    notifyListeners();

    try {
      await ordenTrabajoService.cambiarEstadoOrden(
        ordenId: ordenId,
        nuevoEstado: nuevoEstado,
        versionLocal: versionLocal,
      );

      mensajeDeExitoVisible = 'Estado actualizado a: $nuevoEstado';
      
      // Recarga la orden desde Firestore
      ordenSeleccionada = await obtenerOrdenPorId(ordenId);
      
      estaCambiandoEstado = false;
      notifyListeners();

      // Limpiar mensaje de éxito después de 2 segundos
      await Future.delayed(const Duration(seconds: 2));
      limpiarExito();
    } on Exception catch (e) {
      mensajeDeErrorVisible = e.toString().replaceAll('Exception: ', '');
      estaCambiandoEstado = false;
      notifyListeners();

      // Recarga la orden desde Firestore (el usuario verá la versión actualizada)
      ordenSeleccionada = await obtenerOrdenPorId(ordenId);
      notifyListeners();
    }
  }

  /// Crea una nueva orden de trabajo
  Future<bool> crearOrden({
    required String descripcion,
    required DateTime fechaEntrega,
    required String prioridad,
    required String operarioId,
    required String userRole,
  }) async {
    estaCreando = true;
    limpiarError();
    notifyListeners();

    try {
      await ordenTrabajoService.crearOrden(
        descripcion: descripcion,
        fechaEntrega: fechaEntrega,
        prioridad: prioridad,
        operarioId: operarioId,
        userRole: userRole,
      );

      mensajeDeExitoVisible = 'Orden de trabajo creada con éxito';
      estaCreando = false;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 2));
      limpiarExito();
      return true;
    } catch (e) {
      mensajeDeErrorVisible = e.toString().replaceAll('Exception: ', '');
      estaCreando = false;
      notifyListeners();
      return false;
    }
  }

  /// Selecciona una orden para ver/editar sus detalles
  Future<void> seleccionarOrden(String ordenId) async {
    ordenSeleccionada = await obtenerOrdenPorId(ordenId);
    notifyListeners();
  }

  @override
  void dispose() {
    _ordenesSubscription?.cancel();
    super.dispose();
  }
}
