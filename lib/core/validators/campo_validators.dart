import 'package:rut_validator/rut_validator.dart';
import '../constants/app_config.dart';

/// [RF2] [RF13] Validadores centralizados para campos del formulario
/// Separados para facilitar testing y reutilización
class CampoValidators {
  // Constructor privado para evitar instanciación
  CampoValidators._();

  /// [RF2] Valida nombre completo: obligatorio, mín 3 caracteres, solo letras y espacios
  static String? validarNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre completo es obligatorio';
    }
    
    value = value.trim();
    
    if (value.length < AppConfig.nombreMinChars) {
      return 'El nombre debe tener al menos ${AppConfig.nombreMinChars} caracteres';
    }
    
    if (value.length > AppConfig.nombreMaxChars) {
      return 'El nombre no puede exceder ${AppConfig.nombreMaxChars} caracteres';
    }
    
    // Solo permite letras (incluyendo acentos) y espacios
    if (!RegExp(r'^[a-záéíóúñA-ZÁÉÍÓÚÑ\s]+$').hasMatch(value)) {
      return 'El nombre solo puede contener letras y espacios';
    }
    
    return null;
  }

  /// [RF13] Valida RUT chileno usando el componente centralizado de validación
  static String? validarRut(String? value) {
    if (value == null || value.isEmpty) {
      return 'El RUT es obligatorio';
    }
    
    // Invoca al validador centralizado (Módulo 11)
    return RutValidator.validarParaFormulario(value);
  }

  /// [RF13] Valida correo electrónico: obligatorio, con @ y punto
  static String? validarCorreo(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    
    value = value.trim();
    
    // Validación simple pero efectiva: contiene @ y al menos un punto
    if (!value.contains('@')) {
      return 'El correo debe contener @';
    }
    
    if (!value.contains('.')) {
      return 'El correo debe contener un dominio válido';
    }
    
    // Verifica estructura básica: usuario@dominio.extensión
    final partes = value.split('@');
    if (partes.length != 2 || partes[0].isEmpty || partes[1].isEmpty) {
      return 'Formato de correo inválido';
    }
    
    return null;
  }

  /// [RF2] Valida cargo: obligatorio y debe existir en el sistema
  static String? validarCargo(String? value) {
    if (value == null) {
      return 'Debes seleccionar un cargo';
    }
    
    if (!AppConfig.cargoValido(value)) {
      return 'El cargo seleccionado no existe en el sistema';
    }
    
    return null;
  }

  /// [RF13] Valida rol: obligatorio, debe existir y ser válido para el cargo
  static String? validarRol(String? value, String? cargoSeleccionado) {
    if (value == null) {
      return 'Debes seleccionar un rol';
    }
    
    if (!AppConfig.rolValido(value)) {
      return 'El rol seleccionado no existe en el sistema';
    }
    
    // Valida que el rol sea permitido para el cargo seleccionado
    if (cargoSeleccionado != null && 
        !AppConfig.combinacionValida(cargoSeleccionado, value)) {
      return 'El rol "$value" no es válido para el cargo "$cargoSeleccionado"';
    }
    
    return null;
  }

  /// [RF2] Valida sueldo base: solo números, mayor a 0, mínimo legal
  static String? validarSueldo(String? value) {
    if (value == null || value.isEmpty) {
      return 'El sueldo base es obligatorio';
    }
    
    // Solo números enteros
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'El sueldo solo puede contener números enteros';
    }
    
    final sueldo = double.tryParse(value);
    
    if (sueldo == null || sueldo <= 0) {
      return 'El sueldo debe ser mayor a \$0';
    }
    
    if (sueldo < AppConfig.sueldoMinimoLegal) {
      return 'El sueldo no puede ser inferior a \$${AppConfig.sueldoMinimoLegal.toStringAsFixed(0)} (sueldo mínimo legal)';
    }
    
    return null;
  }
}
