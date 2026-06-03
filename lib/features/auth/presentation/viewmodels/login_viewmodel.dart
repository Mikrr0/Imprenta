import 'package:flutter/material.dart';
import 'package:proyecto/features/auth/domain/usecases/login_usecase.dart';
import 'package:proyecto/core/models/perfil_trabajador.dart';
import 'package:proyecto/core/validators/campo_validators.dart';
import 'package:proyecto/core/constants/app_config.dart'; 

class LoginViewModel extends ChangeNotifier {
  bool estaCargandoDatos = false;
  bool estaRegistrando = false; 
  String? mensajeDeErrorVisible;
  int contadorIntentosFallidos = 0;
  
 
  PerfilTrabajador? usuarioActual;
  
  
  final LoginUseCase loginUseCase;

  LoginViewModel({required this.loginUseCase});

  Future<bool> procesarInicioDeSesion(String rutIngresado, String contrasenaIngresada) async {
    estaCargandoDatos = true;
    mensajeDeErrorVisible = null;
    notifyListeners(); 

    // 1. Verificación de Bloqueo de Seguridad 
    if (contadorIntentosFallidos >= 5) {
      estaCargandoDatos = false;
      mensajeDeErrorVisible = "Cuenta bloqueada temporalmente por 15 minutos tras 5 intentos fallidos.";
      notifyListeners();
      return false;
    }

    // 2. Validaciones de formato iniciales de Benjamín
    final errorRut = CampoValidators.validarRut(rutIngresado.trim());
    if (errorRut != null) {
      estaCargandoDatos = false;
      mensajeDeErrorVisible = errorRut; 
      notifyListeners();
      return false;
    }

    // 3. Conexión Real a Firebase Auth a través del UseCase
    try {
      // Intentamos iniciar sesión con los datos del emulador
      final perfil = await loginUseCase.execute(rutIngresado.trim(), contrasenaIngresada);
      
      // Si la base de datos responde con éxito:
      usuarioActual = perfil;
      contadorIntentosFallidos = 0; // Reiniciamos los intentos fallidos
      estaCargandoDatos = false;
      notifyListeners(); 
      return true; 

    } catch (e) {
      // Si Firebase rechaza la contraseña o el usuario no existe, entra aquí:
      contadorIntentosFallidos++; 
      estaCargandoDatos = false;

      if (contadorIntentosFallidos >= 5) {
        mensajeDeErrorVisible = "Cuenta bloqueada temporalmente por 15 minutos tras 5 intentos fallidos.";
      } else {
        mensajeDeErrorVisible = "Credenciales incorrectas o usuario no registrado. Intento $contadorIntentosFallidos de 5.";
      }
      
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
      
      estaRegistrando = false;
      notifyListeners();
      return true; 
      
    } catch (e) {
      estaRegistrando = false;
      
      // Convertimos el error a texto en minúsculas para buscar palabras clave
      String errorCrudo = e.toString().toLowerCase();

      // Interceptamos errores de Firebase sin exponer la API (BUG-02)
      if (errorCrudo.contains('email-already-in-use') || errorCrudo.contains('already exists')) {
        mensajeDeErrorVisible = "El RUT ya se encuentra registrado."; 
      } else if (errorCrudo.contains('weak-password')) {
        mensajeDeErrorVisible = "La contraseña ingresada es demasiado débil.";
      } else if (errorCrudo.contains('network') || errorCrudo.contains('connection')) {
        mensajeDeErrorVisible = "Error de conexión. Revisa tu acceso a internet.";
      } else {
        // Mensaje genérico para cualquier otra excepción cruda
        mensajeDeErrorVisible = "Ocurrió un error en el servidor al intentar registrar.";
      }

      notifyListeners();
      return false;
    }
  }
}