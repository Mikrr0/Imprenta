import "package:flutter/material.dart";

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFD),
      primaryColor: const Color(0xFF0056b3), // Actualizado según Sprint 5
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0056b3), // Azul UI Kit global
        secondary: Color(0xFFf9a825), // Amarillo para advertencias
        error: Color(0xFFd32f2f), // Rojo para errores de sincronización
        surface: Colors.white,
      ),
      textTheme: ThemeData.light().textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0056b3), // Actualizado según Sprint 5
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFF0056b3).withValues(alpha: 0.15),
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFF0056b3).withValues(alpha: 0.15),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF0056b3),
            width: 1.8,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0056b3), // Actualizado según Sprint 5
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: Colors.white,
        headerBackgroundColor: Color(0xFF0056b3), // Cabecera azul
        headerForegroundColor: Colors.white, // Texto de la cabecera
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121826),
      primaryColor: const Color(0xFF6FA8DC), // Mantenemos el azul claro para modo oscuro
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6FA8DC),
        secondary: Color(0xFFf9a825), // Amarillo para advertencias
        error: Color(0xFFd32f2f), // Rojo para errores críticos
        surface: Color(0xFF1B2430),
      ),
      textTheme: ThemeData.dark().textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B2430),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: const Color(0xFF1B2430),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF6FA8DC),
            width: 1.8,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6FA8DC),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: Color(0xFF1E293B), // Fondo oscuro
        headerBackgroundColor: Color(0xFF0056b3), // Cabecera azul (se mantiene)
        headerForegroundColor: Colors.white, // Texto de la cabecera
      ),
    );
  }
}