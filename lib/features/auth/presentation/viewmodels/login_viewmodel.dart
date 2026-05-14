import "package:flutter/material.dart";

class LoginViewModel extends ChangeNotifier {
  bool estaCargandoDatos = false;
  String? mensajeDeErrorVisible;
  int contadorIntentosFallidos = 0;

  Future<bool> procesarInicioDeSesion(String rutIngresado, String contrasenaIngresada) async {
    estaCargandoDatos = true;
    mensajeDeErrorVisible = null;
    notifyListeners(); 

    await Future.delayed(const Duration(seconds: 1));

    if (contadorIntentosFallidos >= 5) {
      estaCargandoDatos = false;
      mensajeDeErrorVisible = "Cuenta bloqueada temporalmente por 15 minutos tras 5 intentos fallidos.";
      notifyListeners();
      return false;
    }

    if (contrasenaIngresada != "pass123") {
      contadorIntentosFallidos++; 
      
      if (contadorIntentosFallidos >= 5) {
        mensajeDeErrorVisible = "Cuenta bloqueada temporalmente por 15 minutos tras 5 intentos fallidos.";
      } else {
        mensajeDeErrorVisible = "Credenciales incorrectas. Intento $contadorIntentosFallidos de 5.";
      }
      
      estaCargandoDatos = false;
      notifyListeners();
      return false;
    }

    estaCargandoDatos = false;
    contadorIntentosFallidos = 0; 
    notifyListeners(); 
    return true; 
  }
}