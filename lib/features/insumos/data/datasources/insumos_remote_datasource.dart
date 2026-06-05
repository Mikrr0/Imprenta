// Archivo: lib/features/insumos/data/datasources/insumos_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/core/models/insumo.dart';

abstract class InsumosRemoteDataSource {
  Stream<List<Insumo>> obtenerInsumosStream();
  Future<void> crearInsumo(Insumo insumo);
  Future<void> actualizarInsumo(Insumo insumo);
  Future<void> eliminarInsumo(String id);
  Future<Map<String, List<String>>> obtenerParametrosConfiguracion();
}

class InsumosRemoteDataSourceImpl implements InsumosRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _coleccion = 'insumos';

  // --- NUEVO MÉTODO PRIVADO: Sincronización Silenciosa ---
  Future<void> _sincronizarParametros(Insumo insumo) async {
    final docRef = _firestore.collection('configuraciones').doc('insumos');
    
    // FieldValue.arrayUnion agrega el elemento SOLO si no existe en la lista.
    // SetOptions(merge: true) evita que se borre el resto del documento si falta un campo.
    await docRef.set({
      'tiposPapel': FieldValue.arrayUnion([insumo.tipoPapel]),
      'gramajes': FieldValue.arrayUnion([insumo.gramaje]),
      'tamanos': FieldValue.arrayUnion([insumo.tamano]),
    }, SetOptions(merge: true));
  }

  @override
  Future<Map<String, List<String>>> obtenerParametrosConfiguracion() async {
    final docRef = _firestore.collection('configuraciones').doc('insumos');
    final doc = await docRef.get();
    
    // --- DATABASE SEEDING (Auto-configuración inicial) ---
    if (!doc.exists || doc.data() == null) {
      final parametrosPorDefecto = {
        'tiposPapel': ['Couché', 'Bond', 'Opalina', 'Kraft', 'Autoadhesivo', 'Cartulina', 'Otro'],
        'gramajes': ['75g', '90g', '130g', '170g', '300g', 'Otro'],
        'tamanos': ['Carta', 'Oficio', 'A3', 'A4', 'Pliego', 'Medio Pliego', 'Otro'],
      };
      
      // Creamos el documento en Firebase automáticamente
      await docRef.set(parametrosPorDefecto);
      return parametrosPorDefecto;
    }

    // Si ya existe, simplemente lo leemos
    final data = doc.data()!;
    return {
      'tiposPapel': List<String>.from(data['tiposPapel'] ?? []),
      'gramajes': List<String>.from(data['gramajes'] ?? []),
      'tamanos': List<String>.from(data['tamanos'] ?? []),
    };
  }

  @override
  Stream<List<Insumo>> obtenerInsumosStream() {
    return _firestore.collection(_coleccion).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Insumo.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> crearInsumo(Insumo insumo) async {
    final query = await _firestore.collection(_coleccion)
        .where('nombre', isEqualTo: insumo.nombre)
        .where('tipoPapel', isEqualTo: insumo.tipoPapel)
        .where('gramaje', isEqualTo: insumo.gramaje)
        .where('tamano', isEqualTo: insumo.tamano)
        .get();

    if (query.docs.isNotEmpty) {
      throw Exception("Ya existe un insumo registrado con estas características exactas.");
    }

    // 1. Guardamos el insumo en el catálogo
    await _firestore.collection(_coleccion).add(insumo.toMap());
    
    // 2. MÁGIA: Sincronizamos las listas de configuración en segundo plano
    await _sincronizarParametros(insumo);
  }

  @override
  Future<void> actualizarInsumo(Insumo insumo) async {
    if (insumo.id == null) throw Exception("ID de insumo nulo al intentar actualizar");
    
    // 1. Actualizamos el insumo en el catálogo
    await _firestore.collection(_coleccion).doc(insumo.id).update(insumo.toMap());

    // 2. MÁGIA: Sincronizamos por si al editar, el Administrador cambió algo a una opción nueva
    await _sincronizarParametros(insumo);
  }

  @override
  Future<void> eliminarInsumo(String id) async {
    await _firestore.collection(_coleccion).doc(id).delete();
  }
}