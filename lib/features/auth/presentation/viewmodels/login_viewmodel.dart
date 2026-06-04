import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:proyecto/features/auth/domain/usecases/login_usecase.dart';
import 'package:proyecto/core/models/perfil_trabajador.dart';
import 'package:proyecto/core/validators/campo_validators.dart';
import 'package:proyecto/core/constants/app_config.dart'; 

class LoginViewModel extends ChangeNotifier {
  bool estaCargandoDatos = false;
  bool estaRegistrando = false; 
  String? mensajeDeErrorVisible;
  int contadorIntentosFallidos = 0;

  // --- LIMPIEZA DE ERRORES VISUALES ---
  void limpiarError() {
    if (mensajeDeErrorVisible != null) {
      mensajeDeErrorVisible = null;
      notifyListeners();
    }
  }
  
  PerfilTrabajador? usuarioActual;
  final LoginUseCase loginUseCase;

  // --- MOTOR REACTIVO DE SEGURIDAD (CERO PROCESOS ZOMBI) ---
  StreamSubscription<PerfilTrabajador>? _usuarioSubscription;
  bool _bloquearEscuchaPorRegistro = false;

  LoginViewModel({required this.loginUseCase});

  /// [RF14 c] Inicializa la escucha activa en tiempo real sobre el documento de Firestore
  void _iniciarEscuchaSesionViva(String uid) async {
    // 1. Destruye suscripciones huérfanas antes de iniciar una nueva
    await _usuarioSubscription?.cancel();
    _usuarioSubscription = null;

    _usuarioSubscription = loginUseCase.authRepository
        .obtenerUsuarioStream(uid)
        .listen((perfilSincronizado) async {
      
      // 2. Si el Admin está guardando a un trabajador nuevo, ignorar cambios temporales
      if (_bloquearEscuchaPorRegistro) return;

      try {
        // 3. Validación nativa: Si la cuenta se inhabilitó en Auth, expulsa al usuario
        final user = firebase_auth.FirebaseAuth.instance.currentUser;
        if (user != null) await user.getIdTokenResult(true); 
      } catch (e) {
        String errorStr = e.toString().toLowerCase();
        if (errorStr.contains('user-disabled') || errorStr.contains('auth/user-disabled')) {
          _ejecutarCierreDeSesionForzado("Esta cuenta ha sido inhabilitada por el administrador.");
          return;
        }
      }

      // 4. Validación por BD: Si cambian su rol o cargo en caliente, lo expulsa por seguridad
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
      // Reconocemos el candado si un admin lo inhabilitó mientras estaba adentro
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

    if (contadorIntentosFallidos >= 5) {
      estaCargandoDatos = false;
      mensajeDeErrorVisible = "Cuenta bloqueada temporalmente por 15 minutos tras 5 intentos fallidos.";
      notifyListeners();
      return false;
    }

    final errorRut = CampoValidators.validarRut(rutIngresado.trim());
    if (errorRut != null) {
      estaCargandoDatos = false;
      mensajeDeErrorVisible = errorRut; 
      notifyListeners();
      return false;
    }

    try {
      final perfil = await loginUseCase.execute(rutIngresado.trim(), contrasenaIngresada);
      usuarioActual = perfil;
      contadorIntentosFallidos = 0; 

      final currentUid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (currentUid != null) {
        _iniciarEscuchaSesionViva(currentUid);
      }

      estaCargandoDatos = false;
      notifyListeners(); 
      return true; 

    } catch (e) { 
      estaCargandoDatos = false;

      // Reconocemos el candado si intenta iniciar sesión estando inhabilitado
      if (e.toString().contains('CUENTA_INHABILITADA')) {
        mensajeDeErrorVisible = "Esta cuenta ha sido inhabilitada. Contacta a administración.";
        notifyListeners();
        return false; // Retornamos falso sin sumar intentos de fuerza bruta
      }
      contadorIntentosFallidos++;
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

    // Validaciones
    if (CampoValidators.validarNombre(nombre.trim()) != null) return _abortarRegistro(CampoValidators.validarNombre(nombre.trim())!);
    if (CampoValidators.validarRut(rut.trim()) != null) return _abortarRegistro(CampoValidators.validarRut(rut.trim())!);
    if (CampoValidators.validarCorreo(correo.trim()) != null) return _abortarRegistro(CampoValidators.validarCorreo(correo.trim())!);
    if (CampoValidators.validarSueldo(sueldoTexto.trim()) != null) return _abortarRegistro(CampoValidators.validarSueldo(sueldoTexto.trim())!);
    if (CampoValidators.validarContrasena(password) != null) return _abortarRegistro(CampoValidators.validarContrasena(password)!);

    if (!AppConfig.combinacionValida(cargo, rol)) {
      return _abortarRegistro('La combinación de cargo y rol no es válida');
    }

    // [Seguridad] Congelamos la escucha para que el SDK de Auth no nos expulse
    _bloquearEscuchaPorRegistro = true;

    try {
      // [RF2] Construimos la entidad canónica real, convirtiendo el string del sueldo a double
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