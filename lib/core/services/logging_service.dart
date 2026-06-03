import 'package:flutter/foundation.dart';
import '../models/perfil_trabajador.dart';

/// [RNF3] [RNF9] Servicio de logging centralizado
/// Registra eventos en consola durante desarrollo
class LoggingService {
  static final LoggingService _instance = LoggingService._internal();

  final List<PerfilTrabajador> _perfilesCreados = [];

  factory LoggingService() {
    return _instance;
  }

  LoggingService._internal();

  /// Registra la creacion exitosa de un perfil
  void registrarCreacionExitosa(PerfilTrabajador perfil) {
    _perfilesCreados.add(perfil);

    if (kDebugMode) {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('✓ PERFIL DE TRABAJADOR CREADO EXITOSAMENTE');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('Timestamp: ${DateTime.now().toIso8601String()}');
      debugPrint('');
      debugPrint('DATOS DEL PERFIL:');
      debugPrint('  • Nombre: ${perfil.nombreCompleto}');
      debugPrint('  • RUT: ${perfil.rut}');
      debugPrint('  • Correo: ${perfil.correoElectronico}');
      debugPrint('  • Cargo: ${perfil.cargo}');
      debugPrint('  • Rol: ${perfil.rol}');
      debugPrint('  • Sueldo: \$${perfil.sueldoBase.toStringAsFixed(0)}');
      debugPrint('');
      debugPrint('Total de perfiles creados: ${_perfilesCreados.length}');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');

      // Muestra lista de todos los usuarios creados
      _mostrarListaDeUsuarios();
    }
  }

  /// Registra un error en el proceso
  void registrarError(String titulo, String detalle) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('───────────────────────────────────────────────────────────');
      debugPrint('✗ ERROR: $titulo');
      debugPrint('───────────────────────────────────────────────────────────');
      debugPrint('Detalle: $detalle');
      debugPrint('Timestamp: ${DateTime.now().toIso8601String()}');
      debugPrint('───────────────────────────────────────────────────────────');
      debugPrint('');
    }
  }

  /// Muestra la lista de todos los perfiles creados
  void _mostrarListaDeUsuarios() {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('┌─────────────────────────────────────────────────────────┐');
      debugPrint('│          LISTADO DE USUARIOS CREADOS EN SESIÓN          │');
      debugPrint('├─────────────────────────────────────────────────────────┤');

      if (_perfilesCreados.isEmpty) {
        debugPrint('│ No hay usuarios creados en esta sesion                  │');
      } else {
        for (int i = 0; i < _perfilesCreados.length; i++) {
          final perfil = _perfilesCreados[i];
          debugPrint('│ [$i + 1] ${perfil.nombreCompleto.padRight(45)} │');
          debugPrint('│     RUT: ${perfil.rut.padRight(41)} │');
          debugPrint('│     Cargo: ${perfil.cargo.padRight(38)} │');
        }
      }

      debugPrint('├─────────────────────────────────────────────────────────┤');
      debugPrint('│ Total: ${_perfilesCreados.length.toString().padRight(49)} │');
      debugPrint('└─────────────────────────────────────────────────────────┘');
      debugPrint('');
    }
  }

  /// Obtiene todos los perfiles creados
  List<PerfilTrabajador> obtenerPerfilesCreados() {
    return List.unmodifiable(_perfilesCreados);
  }

  /// Limpia el historial de perfiles (uso administrativo)
  void limpiarHistorial() {
    _perfilesCreados.clear();
    if (kDebugMode) {
      debugPrint('[LOG] Historial de perfiles limpiado');
    }
  }
}
