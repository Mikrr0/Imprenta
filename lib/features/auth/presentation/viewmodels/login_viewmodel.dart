<<<<<<< HEAD
import "package:flutter/material.dart";
=======
import 'package:flutter/material.dart';
import 'package:proyecto/features/auth/domain/usecases/login_usecase.dart';
import 'package:proyecto/core/models/perfil_trabajador.dart';
import 'package:proyecto/core/validators/campo_validators.dart';
import 'package:proyecto/core/constants/app_config.dart'; 
>>>>>>> 3609fb357747adcd105deabc0ff4769b80c7e55b

class LoginViewModel extends ChangeNotifier {
  bool estaCargandoDatos = false;
  String? mensajeDeErrorVisible;
  int contadorIntentosFallidos = 0;

  Future<bool> procesarInicioDeSesion(String rutIngresado, String contrasenaIngresada) async {
    estaCargandoDatos = true;
    mensajeDeErrorVisible = null;
    notifyListeners(); 

<<<<<<< HEAD
    await Future.delayed(const Duration(seconds: 1));

    if (contadorIntentosFallidos >= 5) {
=======
    // Validaciones de formato iniciales
    final errorRut = CampoValidators.validarRut(rutIngresado.trim());
    if (errorRut != null) {
>>>>>>> 3609fb357747adcd105deabc0ff4769b80c7e55b
      estaCargandoDatos = false;
      mensajeDeErrorVisible = "Cuenta bloqueada temporalmente por 15 minutos tras 5 intentos fallidos.";
      notifyListeners();
      return false;
    }

    if (contrasenaIngresada != "pass123") {
      contadorIntentosFallidos++; 
<<<<<<< HEAD
=======
      estaCargandoDatos = false;

      mensajeDeErrorVisible = "Contraseña o usuario incorrecto"; 
      
      notifyListeners();
      return false;
    }
  }

  // --- REGISTRO DE TRABAJADOR ---
  Future<bool> registrarTrabajadorCompleto({
    required String nombre,
    required String rut,
    required String correo,
    required String cargo,
    required String rol,
    required String sueldoTexto,
    required String password,
  }) async {
    estaRegistrando = true;
    mensajeDeErrorVisible = null;
    notifyListeners();

    // Validaciones centralizadas
    final errorNombre = CampoValidators.validarNombre(nombre.trim());
    if (errorNombre != null) {
      estaRegistrando = false;
      mensajeDeErrorVisible = errorNombre;
      notifyListeners();
      return false;
    }

    final errorRut = CampoValidators.validarRut(rut.trim());
    if (errorRut != null) {
      estaRegistrando = false;
      mensajeDeErrorVisible = errorRut;
      notifyListeners();
      return false;
    }

    final errorCorreo = CampoValidators.validarCorreo(correo.trim());
    if (errorCorreo != null) {
      estaRegistrando = false;
      mensajeDeErrorVisible = errorCorreo;
      notifyListeners();
      return false;
    }

    final errorSueldo = CampoValidators.validarSueldo(sueldoTexto.trim());
    if (errorSueldo != null) {
      estaRegistrando = false;
      mensajeDeErrorVisible = errorSueldo;
      notifyListeners();
      return false;
    }

    // [RF1] [RNF5] Validación de contraseña en capas (security layer)
    final errorContrasena = CampoValidators.validarContrasena(password);
    if (errorContrasena != null) {
      estaRegistrando = false;
      mensajeDeErrorVisible = errorContrasena;
      notifyListeners();
      return false;
    }

    // [RF13] Validación de combinación cargo-rol
    if (!AppConfig.combinacionValida(cargo, rol)) {
      estaRegistrando = false;
      mensajeDeErrorVisible = 'La combinación de cargo y rol no es válida';
      notifyListeners();
      return false;
    }

    try {
      await loginUseCase.registrarNuevoUsuario(
        rut: rut.trim(),
        password: password, 
        nombre: nombre.trim(),
        cargo: cargo,
        rol: rol, 
        estado: true, 
      );
>>>>>>> 3609fb357747adcd105deabc0ff4769b80c7e55b
      
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