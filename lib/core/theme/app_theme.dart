import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// [RNF7] Tema global de la aplicacion
/// Centraliza la configuracion de colores corporativos
class AppTheme {
  AppTheme._();

  /// Tema claro corporativo
  static ThemeData get lightTheme {
    return ThemeData(
      // [RNF7] Color seed corporativo azul
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      
      // Material 3 habilitado
      useMaterial3: true,
    );
  }
}
