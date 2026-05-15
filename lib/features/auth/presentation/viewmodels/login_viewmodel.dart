import 'package:flutter/material.dart';
import 'package:proyecto/features/auth/domain/usecases/login_usecase.dart';
import 'package:proyecto/features/auth/domain/entities/usuario.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  LoginViewModel(this.loginUseCase);

  bool estaCargandoDatos = false;
  bool estaRegistrando = false; 
  String? mensajeDeErrorVisible;
  int contadorIntentosFallidos = 0;
  Usuario? usuarioActual;

  Future<bool> procesarInicioDeSesion(String rutIngresado, String contrasenaIngresada) async {
    estaCargandoDatos = true;
    mensajeDeErrorVisible = null;
    notifyListeners(); 

    try {
      usuarioActual = await loginUseCase.execute(rutIngresado.trim(), contrasenaIngresada);
      estaCargandoDatos = false;
      contadorIntentosFallidos = 0; 
      notifyListeners(); 
      return true; 
    } catch (e) {
      contadorIntentosFallidos++; 
      estaCargandoDatos = false;
      mensajeDeErrorVisible = "Fallo Firebase: $e"; 
      notifyListeners();
      return false;
    }
  }

  // --- EL NUEVO MOTOR DE REGISTRO ---
  Future<bool> crearCuenta(String rut, String password, String nombre) async {
    estaRegistrando = true;
    mensajeDeErrorVisible = null;
    notifyListeners();

    try {
      // Llamamos al UseCase para que haga el trabajo pesado
      await loginUseCase.executeRegister(rut.trim(), password, nombre);
      estaRegistrando = false;
      notifyListeners();
      return true; // ¡Registro exitoso!
    } catch (e) {
      estaRegistrando = false;
      mensajeDeErrorVisible = "Error al registrar: $e";
      notifyListeners();
      return false; // Algo falló (ej: el RUT ya estaba registrado)
    }
  }
}