import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  late ThemeMode _modoActual;

  // Constructor: Lee lo que está guardado en memoria apenas inicia la app
  ThemeProvider(this._prefs) {
    final esOscuroGuardado = _prefs.getBool('esModoOscuro') ?? false;
    _modoActual = esOscuroGuardado ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeMode get modoActual => _modoActual;
  bool get esModoOscuro => _modoActual == ThemeMode.dark;

  void alternarTema() {
    _modoActual = esModoOscuro ? ThemeMode.light : ThemeMode.dark;
    
    // Guardamos la decisión del usuario en el almacenamiento del teléfono
    _prefs.setBool('esModoOscuro', esModoOscuro);
    
    notifyListeners();
  }
}