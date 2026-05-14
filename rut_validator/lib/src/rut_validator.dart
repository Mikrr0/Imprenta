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
    final checkDigit = clean[clean.length - 1];

    // Agrupa los números de 3 en 3 desde la derecha
    final reversed = numbers.split('').reversed.toList();
    final groups = <String>[];

    for (int i = 0; i < reversed.length; i += 3) {
      final group = reversed.sublist(i, (i + 3).clamp(0, reversed.length));
      groups.add(group.reversed.join());
    }

    return '${groups.reversed.join('.')}-$checkDigit';
  }

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