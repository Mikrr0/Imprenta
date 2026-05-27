/// [RF1] [RNF5] Validador especializado de contraseñas
/// Implementa la lógica de validación de contraseñas con expresiones regulares.
/// Requisitos: Mínimo 8 caracteres, al menos 1 MAYÚSCULA, 1 minúscula, 1 número
/// 
/// NOTA: Esta clase encapsula la lógica compleja de RegExp.
/// Desde campo_validators.dart se invoca este validador de forma centralizada.

class PasswordValidator {
  // Constructor privado para evitar instanciación
  PasswordValidator._();

  /// RegExp centralizada que valida:
  /// - (?=.*[A-Z])  : Al menos 1 mayúscula
  /// - (?=.*[a-z])  : Al menos 1 minúscula
  /// - (?=.*\d)     : Al menos 1 número
  /// - .{8,}        : Mínimo 8 caracteres
  static final RegExp _regexContrasena = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$',
  );

  /// [RF1] [RNF5] Valida contraseña según criterios estrictos
  /// 
  /// Retorna:
  /// - null si la contraseña es válida
  /// - String con mensaje de error específico si no cumple requisito
  static String? validar(String password) {
    if (password.isEmpty) {
      return 'La contraseña es obligatoria';
    }

    if (password.length < 8) {
      return 'La contraseña debe tener mínimo 8 caracteres';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'La contraseña debe contener al menos 1 letra MAYÚSCULA';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'La contraseña debe contener al menos 1 letra minúscula';
    }

    if (!RegExp(r'\d').hasMatch(password)) {
      return 'La contraseña debe contener al menos 1 número';
    }

    // Si pasa todas las validaciones individuales, verifica con RegExp completa
    if (!_regexContrasena.hasMatch(password)) {
      return 'La contraseña no cumple los requisitos de seguridad';
    }

    return null;
  }

  /// Valida y retorna true/false (útil para operaciones no-UI)
  static bool esValida(String password) {
    return validar(password) == null;
  }

  /// Retorna descripción de requisitos para documentación
  static String obtenerRequisitos() {
    return 'Mínimo 8 caracteres, 1 mayúscula, 1 minúscula, 1 número';
  }
}
