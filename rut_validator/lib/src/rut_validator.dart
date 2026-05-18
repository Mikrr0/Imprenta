enum RutValidationError {
  empty,
  invalidFormat,
  invalidCheckDigit,
  invalidLength,
  nonNumericBody,
}

class RutValidationResult {
  final bool isValid;
  final RutValidationError? error;
  final String? formattedRut;
  final String? errorMessage;

  RutValidationResult({
    required this.isValid,
    this.error,
    this.formattedRut,
    this.errorMessage,
  });
}

class RutValidator {
  /// Valida un RUT chileno
  /// Acepta formatos: "12345678-9" o "123456789"
  static bool validate(String rut) {
    final clean = _removeFormat(rut);
    if (clean.length < 2) return false;

    final numbers = clean.substring(0, clean.length - 1);
    final checkDigit = clean[clean.length - 1].toUpperCase();

    // Verifica que el cuerpo sea solo números
    if (int.tryParse(numbers) == null) return false;

    // Compara el dígito verificador
    return _calculateCheckDigit(numbers) == checkDigit;
  }

  /// Calcula el dígito verificador para un RUT
  static String computeDv(String rutNumbers) {
    return _calculateCheckDigit(rutNumbers);
  }

  /// Formatea un RUT al estilo "12.345.678-9"
  static String format(String rut) {
    final clean = _removeFormat(rut);
    if (clean.length < 2) return rut;

    final numbers = clean.substring(0, clean.length - 1);
    final checkDigit = clean[clean.length - 1].toUpperCase();

    // Agrupa los números de 3 en 3 desde la derecha
    final reversed = numbers.split('').reversed.toList();
    final groups = <String>[];

    for (int i = 0; i < reversed.length; i += 3) {
      final group = reversed.sublist(i, (i + 3).clamp(0, reversed.length));
      groups.add(group.reversed.join());
    }

    return '${groups.reversed.join('.')}-$checkDigit';
  }

  /// Valida un RUT y retorna resultado detallado con error específico
  static RutValidationResult validateDetailed(String? value) {
    if (value == null || value.isEmpty) {
      return RutValidationResult(
        isValid: false,
        error: RutValidationError.empty,
        errorMessage: 'El RUT no puede estar vacío',
      );
    }

    final clean = _removeFormat(value);

    if (clean.length < 8 || clean.length > 9) {
      return RutValidationResult(
        isValid: false,
        error: RutValidationError.invalidLength,
        errorMessage: 'El RUT debe tener entre 8 y 9 caracteres',
      );
    }

    final numbers = clean.substring(0, clean.length - 1);
    final checkDigit = clean[clean.length - 1].toUpperCase();

    if (int.tryParse(numbers) == null) {
      return RutValidationResult(
        isValid: false,
        error: RutValidationError.nonNumericBody,
        errorMessage: 'El RUT solo puede contener números y K',
      );
    }

    final expectedCheckDigit = _calculateCheckDigit(numbers);
    if (expectedCheckDigit != checkDigit) {
      return RutValidationResult(
        isValid: false,
        error: RutValidationError.invalidCheckDigit,
        errorMessage: 'Rut Inválido',
      );
    }

    return RutValidationResult(
      isValid: true,
      formattedRut: format(value),
    );
  }

  /// Validator compatible con TextFormField
  /// Retorna null si es válido, o mensaje de error si no
  static String? formFieldValidator(String? value) => 
    validateDetailed(value).isValid 
      ? null 
      : validateDetailed(value).errorMessage;

  /// Elimina puntos, guiones y espacios del RUT
  static String _removeFormat(String rut) {
    return rut.replaceAll(RegExp(r'[.\-\s]'), '').trim();
  }

  /// Calcula el dígito verificador usando el algoritmo módulo 11
  static String _calculateCheckDigit(String rutNumbers) {
    const multipliers = [2, 3, 4, 5, 6, 7]; // Se repite cíclicamente
    int sum = 0;

    // Multiplica cada dígito (de derecha a izquierda) por su multiplicador
    final digits = rutNumbers.split('').reversed.toList();
    for (int i = 0; i < digits.length; i++) {
      sum += int.parse(digits[i]) * multipliers[i % multipliers.length];
    }

    // Calcula el dígito verificador
    final remainder = (11 - (sum % 11)) % 11;
    if (remainder == 10) return 'K';
    return remainder.toString();
  }
}