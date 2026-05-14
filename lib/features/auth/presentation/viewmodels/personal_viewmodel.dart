import "package:flutter/material.dart";

class PersonalViewModel extends ChangeNotifier {
  List<Map<String, String>> listaDeTrabajadoresGuardados = [];

  void registrarNuevoTrabajador(
    String nombreCompleto, 
    String rut, 
    String correoLaboral, 
    String cargoAsignado, 
    String rolDePermisos
  ) {
    listaDeTrabajadoresGuardados.add({
      "nombre": nombreCompleto,
      "rut": rut,
      "correo": correoLaboral,
      "cargo": cargoAsignado,
      "rol": rolDePermisos,
    });
    
    notifyListeners(); 
  }
}