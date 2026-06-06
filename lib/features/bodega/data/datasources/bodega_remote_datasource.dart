import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/core/models/movimiento_bodega.dart';
import 'package:proyecto/core/models/proveedor.dart';

abstract class BodegaRemoteDataSource {
  Stream<List<Proveedor>> obtenerProveedoresStream();
  Future<void> registrarProveedor(Proveedor proveedor);
  Future<void> registrarIngresoBodega(MovimientoBodega movimiento);
}

class BodegaRemoteDataSourceImpl implements BodegaRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<Proveedor>> obtenerProveedoresStream() {
    return _firestore
        .collection('proveedores')
        .where('estado', isEqualTo: true) // Solo traemos proveedores activos
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Proveedor.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> registrarProveedor(Proveedor proveedor) async {
    // Validar que el RUT no esté duplicado
    final query = await _firestore
        .collection('proveedores')
        .where('rut', isEqualTo: proveedor.rut)
        .get();

    if (query.docs.isNotEmpty) {
      throw Exception("El proveedor con este RUT ya se encuentra registrado.");
    }

    await _firestore.collection('proveedores').add(proveedor.toMap());
  }

  @override
  Future<void> registrarIngresoBodega(MovimientoBodega movimiento) async {
    final insumoRef = _firestore.collection('insumos').doc(movimiento.insumoId);
    final movimientoRef = _firestore.collection('movimientos_bodega').doc();

    // Utilizamos una Transacción para asegurar la integridad de los datos (Evitar Race Conditions)
    await _firestore.runTransaction((transaction) async {
      final insumoSnapshot = await transaction.get(insumoRef);

      if (!insumoSnapshot.exists) {
        throw Exception("El insumo seleccionado ya no existe en la base de datos.");
      }

      // 1. Calculamos el nuevo stock
      final int stockActual = insumoSnapshot.data()?['stock'] ?? 0;
      final int nuevoStock = stockActual + movimiento.cantidadIngresada;

      // 2. Actualizamos el stock en el catálogo de insumos (Cumplimiento HU03)
      transaction.update(insumoRef, {'stock': nuevoStock});

      // 3. Dejamos el registro histórico del movimiento en bodega
      transaction.set(movimientoRef, movimiento.toMap());
    });
  }
}