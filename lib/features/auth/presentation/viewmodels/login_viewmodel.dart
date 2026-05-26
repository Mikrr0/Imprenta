import 'package:flutter/material.dart';
import 'package:proyecto/features/auth/domain/usecases/login_usecase.dart';
import 'package:proyecto/core/models/perfil_trabajador.dart';
import 'package:proyecto/core/validators/campo_validators.dart'; 

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  LoginViewModel(this.loginUseCase);

  bool estaCargandoDatos = false;
  bool estaRegistrando = false;
  String? mensajeDeErrorVisible;
  int contadorIntentosFallidos = 0;
  PerfilTrabajador? usuarioActual;

  // --- INICIO DE SESIÓN CONECTADO ---
  Future<bool> procesarInicioDeSesion(String rutIngresado, String contrasenaIngresada) async {
    estaCargandoDatos = true;
    mensajeDeErrorVisible = null;
    notifyListeners(); 

    // Validaciones de formato iniciales
    final errorRut = CampoValidators.validarRut(rutIngresado.trim());
    if (errorRut != null) {
      estaCargandoDatos = false;
      mensajeDeErrorVisible = errorRut; 
      notifyListeners();
      return false;
    }

    try {
      usuarioActual = await loginUseCase.execute(rutIngresado.trim(), contrasenaIngresada);
      estaCargandoDatos = false;
      contadorIntentosFallidos = 0; 
      notifyListeners(); 
      return true; 
    } catch (e) {
      contadorIntentosFallidos++; 
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

    try {
      await loginUseCase.registrarNuevoUsuario(
        rut: rut.trim(),
        password: password, 
        nombre: nombre.trim(),
        rol: rol, 
        estado: true, 
      );
      
      estaRegistrando = false;
      notifyListeners();
      return true;
    } catch (e) {
      estaRegistrando = false;
      mensajeDeErrorVisible = "Error en Firebase: $e";
      notifyListeners();
      return false;
    }
  }
}