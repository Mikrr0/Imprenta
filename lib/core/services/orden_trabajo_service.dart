import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/orden_trabajo.dart';



class OrdenTrabajoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lista estricta de estados válidos según el RF5
  final List<String> _estadosValidos = ['Pendiente', 'En Proceso', 'Detenida', 'Finalizada'];

  /// 1. Crear Orden (Restringido a Jefes o Administradores)
  Future<void> crearOrden({
    required String descripcion,
    required DateTime fechaEntrega,
    required String prioridad,
    required String operarioId,
    required String userRole, // Se pasa desde la sesión actual
  }) async {
    // Validación estricta de roles de seguridad
    if (userRole != 'Jefe' && userRole != 'Administrador') {
      throw Exception('Permiso denegado: Solo Jefes o Administradores pueden crear órdenes.');
    }

    final nuevaOrden = {
      'descripcion': descripcion,
      'fechaCreacion': Timestamp.now(),
      'fechaEntrega': Timestamp.fromDate(fechaEntrega),
      'prioridad': prioridad, // 'Baja', 'Media', 'Alta'
      'operarioId': operarioId,
      'estado': 'Pendiente', // Toda orden nace en Pendiente
      'version': 1, // Inicializa en versión 1
    };

    await _firestore.collection('ordenes_trabajo').add(nuevaOrden);
  }

  /// 2. Actualizar Estado con BLOQUEO OPTIMISTA y VALIDACIÓN DE SECUENCIA
  Future<void> cambiarEstadoOrden({
    required String ordenId,
    required String nuevoEstado,
    required int versionLocal, // La versión que el usuario ve en su pantalla
  }) async {
    // Validar que el estado pertenezca a la lista estricta del RF5
    if (!_estadosValidos.contains(nuevoEstado)) {
      throw Exception('Estado inválido. Debe ser: Pendiente, En Proceso, Detenida o Finalizada.');
    }

    final docRef = _firestore.collection('ordenes_trabajo').doc(ordenId);

    // Usamos una Transacción para asegurar atomicidad y concurrencia pura
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('La orden de trabajo no existe.');
      }

      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      final int versionServidor = data['version'] ?? 1;
      final String estadoServidor = data['estado'] ?? 'Pendiente';

      // VERIFICACIÓN DEL BLOQUEO OPTIMISTA:
      if (versionLocal != versionServidor) {
        throw Exception(
          'CONCURRENCIA: La orden fue modificada por otro usuario mientras operabas. Por favor, actualiza la vista.'
        );
      }

      // VALIDACIÓN DE SECUENCIA OBLIGATORIA DE ESTADOS (RF5)
      bool transicionValida = false;
      switch (estadoServidor) {
        case 'Pendiente':
          if (nuevoEstado == 'En Proceso' || nuevoEstado == 'Detenida') transicionValida = true;
          break;
        case 'En Proceso':
          if (nuevoEstado == 'Detenida' || nuevoEstado == 'Finalizada') transicionValida = true;
          break;
        case 'Detenida':
          if (nuevoEstado == 'En Proceso') transicionValida = true;
          break;
        case 'Finalizada':
          transicionValida = false; // No se puede salir de Finalizada
          break;
      }

      if (!transicionValida) {
        throw Exception(
          'SEGURIDAD: Transición no permitida. No se puede pasar de "$estadoServidor" a "$nuevoEstado".'
        );
      }

      // Si todo es válido, procedemos al cambio e incrementamos la versión del documento
      transaction.update(docRef, {
        'estado': nuevoEstado,
        'version': versionServidor + 1,
      });
    });
  }
    /// 3. Obtener todas las órdenes  
  Future<List<OrdenTrabajo>> obtenerOrdenes() async {
    final snapshot = await _firestore.collection('ordenes_trabajo').get();
    return snapshot.docs.map((doc) => OrdenTrabajo.fromDocument(doc)).toList();
  }
}