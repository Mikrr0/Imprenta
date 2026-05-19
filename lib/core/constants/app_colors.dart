import 'package:flutter/material.dart';

/// [RNF7] Paleta de colores semánticos de la imprenta
/// Define los colores corporativos y de feedback del sistema
class AppColors {
  // Colores principales [RNF7]
  static const Color primary = Color(0xFF0056b3); // Azul corporativo
  static const Color secondary = Color(0xFF1e88e5); // Azul secundario
  
  // Colores de estado [RNF5]
  static const Color error = Color(0xFFd32f2f); // Rojo para errores
  static const Color success = Color(0xFF388e3c); // Verde para éxito
  static const Color warning = Color(0xFFF57C00); // Naranja para advertencias
  static const Color info = Color(0xFF1976D2); // Azul para información
  
  // Colores neutrales
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceVariant = Color(0xFFEEEEEE);
  static const Color onSurface = Color(0xFF1F1F1F);
  static const Color onSurfaceVariant = Color(0xFF767676);
  
  // Constructor privado para evitar instanciación
  AppColors._();
}
