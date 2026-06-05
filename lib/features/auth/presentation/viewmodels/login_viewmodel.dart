import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:proyecto/features/auth/domain/usecases/login_usecase.dart';
import 'package:proyecto/core/models/perfil_trabajador.dart';
import 'package:proyecto/core/validators/campo_validators.dart';
import 'package:proyecto/core/constants/app_config.dart'; 
import 'package:proyecto/core/services/security_service.dart'; 

class LoginViewModel extends ChangeNotifier {
  bool estaCargandoDatos = false;
  bool estaRegistrando = false; 
  String? mensajeDeErrorVisible;
  
  // Limpieza de Errores (Tu código)
  void limpiarError() {
    if (mensajeDeErrorVisible != null) {
      mensajeDeErrorVisible = null;
      notifyListeners();
    }
  }
  
  PerfilTrabajador? usuarioActual;
  final LoginUseCase loginUseCase;
  
  // Servicio de seguridad (Código de Alejandro)
  final SecurityService _securityService = SecurityService();

  StreamSubscription<PerfilTrabajador>? _usuarioSubscription;
  bool _bloquearEscuchaPorRegistro = false;

  LoginViewModel({required this.loginUseCase});

  void _iniciarEscuchaSesionViva(String uid) async {
    await _usuarioSubscription?.cancel();
    _usuarioSubscription = null;

    _usuarioSubscription = loginUseCase.authRepository
        .obtenerUsuarioStream(uid)
        .listen((perfilSincronizado) async {
      
      if (_bloquearEscuchaPorRegistro) return;

      try {
        final user = firebase_auth.FirebaseAuth.instance.currentUser;
        if (user != null) await user.getIdTokenResult(true); 
      } catch (e) {
        String errorStr = e.toString().toLowerCase();
        if (errorStr.contains('user-disabled') || errorStr.contains('auth/user-disabled')) {
          _ejecutarCierreDeSesionForzado("Esta cuenta ha sido inhabilitada por el administrador.");
          return;
        }
      }

      if (usuarioActual != null) {
        if (perfilSincronizado.rol != usuarioActual!.rol || 
            perfilSincronizado.cargo != usuarioActual!.cargo) {
          _ejecutarCierreDeSesionForzado("Tu sesión fue cerrada por cambios de permisos en el servidor.");
          return;
        }
      }
      
      usuarioActual = perfilSincronizado;
      notifyListeners();
    }, onError: (error) {
      if (error.toString().contains('CUENTA_INHABILITADA')) {
        _ejecutarCierreDeSesionForzado("Tu cuenta ha sido inhabilitada por el administrador.");
      } else {
        _ejecutarCierreDeSesionForzado("Inconsistencia detectada en los datos de sesión.");
      }
    });
  }

  void _ejecutarCierreDeSesionForzado(String mensajeAviso) async {
    await _usuarioSubscription?.cancel();
    _usuarioSubscription = null;
    usuarioActual = null;
    mensajeDeErrorVisible = mensajeAviso;
    await loginUseCase.authRepository.logout();
    notifyListeners();
  }

  Future<bool> procesarInicioDeSesion(String rutIngresado, String contrasenaIngresada) async {
    estaCargandoDatos = true;
    mensajeDeErrorVisible = null;
    notifyListeners(); 

    final rutLimpio = rutIngresado.trim();

    // Verificación de Bloqueo de Seguridad en el Backend (Alejandro)
    final bloqueado = await _securityService.estaBloqueado(rutLimpio);
    if (bloqueado) {
      estaCargandoDatos = false;
      mensajeDeErrorVisible = "Por seguridad, cuenta bloqueada por 15 minutos tras 5 intentos fallidos.";
      notifyListeners();
      return false;
    }

    final errorRut = CampoValidators.validarRut(rutLimpio);
    if (errorRut != null) {
      estaCargandoDatos = false;
      mensajeDeErrorVisible = errorRut; 
      notifyListeners();
      return false;
    }

    try {
      final perfil = await loginUseCase.execute(rutLimpio, contrasenaIngresada);
      
      // Éxito: Limpiamos historial en la BD
      await _securityService.resetearIntentos(rutLimpio);
      
      usuarioActual = perfil;
      
      final currentUid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (currentUid != null) {
        _iniciarEscuchaSesionViva(currentUid);
      }

      estaCargandoDatos = false;
      notifyListeners(); 
      return true; 

    } catch (e) { 
      estaCargandoDatos = false;
      
      // Reconocemos candado de inhabilitación (Soft Delete)
      if (e.toString().contains('CUENTA_INHABILITADA')) {
        mensajeDeErrorVisible = "Esta cuenta ha sido inhabilitada. Contacta a administración.";
        notifyListeners();
        return false; 
      }
      
      // Fallo: Registramos en la BD (Alejandro)
      int intentosActuales = await _securityService.registrarIntentoFallido(rutLimpio);
      
      if (intentosActuales >= 5) {
        mensajeDeErrorVisible = "Cuenta bloqueada temporalmente por 15 minutos tras 5 intentos fallidos.";
      } else {
        mensajeDeErrorVisible = "Credenciales incorrectas o usuario no registrado. Intento $intentosActuales de 5.";
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

    if (CampoValidators.validarNombre(nombre.trim()) != null) return _abortarRegistro(CampoValidators.validarNombre(nombre.trim())!);
    if (CampoValidators.validarRut(rut.trim()) != null) return _abortarRegistro(CampoValidators.validarRut(rut.trim())!);
    if (CampoValidators.validarCorreo(correo.trim()) != null) return _abortarRegistro(CampoValidators.validarCorreo(correo.trim())!);
    if (CampoValidators.validarSueldo(sueldoTexto.trim()) != null) return _abortarRegistro(CampoValidators.validarSueldo(sueldoTexto.trim())!);
    if (CampoValidators.validarContrasena(password) != null) return _abortarRegistro(CampoValidators.validarContrasena(password)!);

    if (!AppConfig.combinacionValida(cargo, rol)) {
      return _abortarRegistro('La combinación de cargo y rol no es válida');
    }

    _bloquearEscuchaPorRegistro = true;

    try {
      final nuevoPerfil = PerfilTrabajador(
        nombreCompleto: nombre.trim(),
        rut: rut.trim(),
        correoElectronico: correo.trim().isNotEmpty ? correo.trim() : "$rut@imprenta.cl",
        cargo: cargo,
        rol: rol,
        sueldoBase: double.parse(sueldoTexto.trim()),
      );

      await loginUseCase.registrarUsuario(
        perfil: nuevoPerfil,
        password: password,
        estado: true, 
      );
      
      _bloquearEscuchaPorRegistro = false;
      estaRegistrando = false;
      notifyListeners();
      return true; 
      
    } catch (e) {
      _bloquearEscuchaPorRegistro = false;
      estaRegistrando = false;
      
      String errorCrudo = e.toString().toLowerCase();
      if (errorCrudo.contains('email-already-in-use') || errorCrudo.contains('already exists')) {
        mensajeDeErrorVisible = "El RUT ya se encuentra registrado."; 
      } else if (errorCrudo.contains('weak-password')) {
        mensajeDeErrorVisible = "La contraseña ingresada es demasiado débil.";
      } else if (errorCrudo.contains('network') || errorCrudo.contains('connection')) {
        mensajeDeErrorVisible = "Error de conexión. Revisa tu acceso a internet.";
      } else {
        mensajeDeErrorVisible = "Ocurrió un error en el servidor al intentar registrar.";
      }

      notifyListeners();
      return false;
    }
  }

  bool _abortarRegistro(String motivo) {
    estaRegistrando = false;
    mensajeDeErrorVisible = motivo;
    notifyListeners();
    return false;
  }

  Future<void> procesarCierreDeSesion() async {
    await _usuarioSubscription?.cancel();
    _usuarioSubscription = null;
    usuarioActual = null;
    await loginUseCase.authRepository.logout();
    notifyListeners();
  }

  @override
  void dispose() {
    _usuarioSubscription?.cancel();
    super.dispose();
  }
}