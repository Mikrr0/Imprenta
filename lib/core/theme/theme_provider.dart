import "package:flutter/material.dart";

class ThemeProvider extends ChangeNotifier {
  ThemeMode _modoActual = ThemeMode.light;

  ThemeMode get modoActual => _modoActual;
  bool get esModoOscuro => _modoActual == ThemeMode.dark;

  void alternarTema() {
    _modoActual = esModoOscuro ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}