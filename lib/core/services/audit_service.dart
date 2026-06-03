import 'package:flutter/foundation.dart';
import '../models/perfil_trabajador.dart';

/// [RNF3] [RNF9] Servicio de auditoría para registrar eventos críticos del sistema
/// Facilita trazabilidad y debugging según requerimientos de seguridad
class AuditService {
  static final AuditService _instance = AuditService._internal();

  final List<AuditEvent> _eventos = [];

  factory AuditService() {
    return _instance;
  }

  AuditService._internal();

  /// Registra un intento de creacion de perfil
  void registrarIntentoCreacionPerfil(PerfilTrabajador perfil) {
    _registrarEvento(
      tipo: 'CREACION_PERFIL',
      estado: 'INTENTO',
      descripcion: 'Intento de crear nuevo perfil de trabajador',
      datos: perfil.toLogString(),
    );
  }

  /// Registra error en validación
  void registrarErrorValidacion(String campo, String error) {
    _registrarEvento(
      tipo: 'ERROR_VALIDACION',
      estado: 'FALLO',
      descripcion: 'Error en validación de campo $campo',
      datos: 'Error: $error',
    );
  }

  /// Registra exito en creacion de perfil
  void registrarExitoCreacionPerfil(PerfilTrabajador perfil) {
    _registrarEvento(
      tipo: 'CREACION_PERFIL',
      estado: 'EXITO',
      descripcion: 'Perfil de trabajador creado exitosamente',
      datos: perfil.toLogString(),
    );
  }

  /// Registra limpieza de formulario
  void registrarLimpiezaFormulario() {
    _registrarEvento(
      tipo: 'LIMPIEZA_FORMULARIO',
      estado: 'COMPLETADA',
      descripcion: 'Formulario de creación de perfil limpiado',
    );
  }

  /// Método privado para registrar evento genérico
  void _registrarEvento({
    required String tipo,
    required String estado,
    required String descripcion,
    String? datos,
  }) {
    final evento = AuditEvent(
      timestamp: DateTime.now(),
      tipo: tipo,
      estado: estado,
      descripcion: descripcion,
      datos: datos,
    );

    _eventos.add(evento);

    // En desarrollo, imprime en consola para debugging
    if (kDebugMode) {
      debugPrint('[AUDIT] ${evento.toString()}');
    }
  }

  /// Obtiene todos los eventos registrados
  List<AuditEvent> obtenerEventos() => List.unmodifiable(_eventos);

  /// Limpia el historial de eventos (uso administrativo)
  void limpiarHistorial() {
    _eventos.clear();
    if (kDebugMode) {
      debugPrint('[AUDIT] Historial de auditoría limpiado');
    }
  }

  /// Exporta los eventos en formato legible
  String exportarEvento() {
    return _eventos.map((e) => e.toString()).join('\n');
  }
}

/// Modelo para representar un evento de auditoría
class AuditEvent {
  final DateTime timestamp;
  final String tipo;
  final String estado;
  final String descripcion;
  final String? datos;

  AuditEvent({
    required this.timestamp,
    required this.tipo,
    required this.estado,
    required this.descripcion,
    this.datos,
  });

  @override
  String toString() {
    return '[${timestamp.toIso8601String()}] $tipo | $estado | $descripcion${datos != null ? ' | $datos' : ''}';
  }
}
