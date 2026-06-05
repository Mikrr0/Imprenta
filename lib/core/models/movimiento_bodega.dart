import 'package:cloud_firestore/cloud_firestore.dart';

class MovimientoBodega {
  final String? id;
  final String insumoId;
  final String proveedorId;
  final int cantidadIngresada;
  final DateTime fechaRegistro;
  final String registradoPorUid; // ID del Encargado de Bodega que hizo la acción

  MovimientoBodega({
    this.id,
    required this.insumoId,
    required this.proveedorId,
    required this.cantidadIngresada,
    required this.fechaRegistro,
    required this.registradoPorUid,
  });

  factory MovimientoBodega.fromMap(Map<String, dynamic> data, String documentId) {
    return MovimientoBodega(
      id: documentId,
      insumoId: data['insumoId'] ?? '',
      proveedorId: data['proveedorId'] ?? '',
      cantidadIngresada: data['cantidadIngresada'] ?? 0,
      fechaRegistro: (data['fechaRegistro'] as Timestamp).toDate(),
      registradoPorUid: data['registradoPorUid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'insumoId': insumoId,
      'proveedorId': proveedorId,
      'cantidadIngresada': cantidadIngresada,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'registradoPorUid': registradoPorUid,
    };
  }
}