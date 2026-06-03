import 'package:flutter_test/flutter_test.dart';

import 'package:rut_validator/rut_validator.dart';

void main() {
  group('RutValidator - Métodos Básicos', () {
    test('valida RUTs correctos', () {
      expect(RutValidator.validate('76354771-K'), isTrue);
      expect(RutValidator.validate('76.354.771-K'), isTrue);
      expect(RutValidator.validate('76354771K'), isTrue);
    });

    test('rechaza RUTs inválidos', () {
      expect(RutValidator.validate('12345678-0'), isFalse);
      expect(RutValidator.validate(''), isFalse);
      expect(RutValidator.validate('abc'), isFalse);
    });

    test('formatea correctamente', () {
      expect(RutValidator.format('76354771K'), '76.354.771-K');
      expect(RutValidator.format('76354771-k'), '76.354.771-K');
      expect(RutValidator.format('76.354.771-k'), '76.354.771-K');
    });

    test('calcula dígito verificador correcto', () {
      expect(RutValidator.computeDv('76354771'), 'K');
      expect(RutValidator.computeDv('12345674'), '2');
    });
  });

  group('RutValidator - Validación Detallada', () {
    test('retorna error si RUT está vacío', () {
      final result = RutValidator.validateDetailed('');
      expect(result.isValid, isFalse);
      expect(result.error, RutValidationError.empty);
      expect(result.errorMessage, isNotEmpty);
    });

    test('retorna error si RUT es null', () {
      final result = RutValidator.validateDetailed(null);
      expect(result.isValid, isFalse);
      expect(result.error, RutValidationError.empty);
    });

    test('retorna error si RUT tiene largo inválido', () {
      final result = RutValidator.validateDetailed('1234567');
      expect(result.isValid, isFalse);
      expect(result.error, RutValidationError.invalidLength);
    });

    test('retorna error si cuerpo tiene caracteres no numéricos', () {
      final result = RutValidator.validateDetailed('7635477a-K');
      expect(result.isValid, isFalse);
      expect(result.error, RutValidationError.nonNumericBody);
    });

    test('retorna error si dígito verificador es incorrecto', () {
      final result = RutValidator.validateDetailed('76354771-0');
      expect(result.isValid, isFalse);
      expect(result.error, RutValidationError.invalidCheckDigit);
    });

    test('retorna RUT formateado en validateDetailed válido', () {
      final result = RutValidator.validateDetailed('76354771K');
      expect(result.isValid, isTrue);
      expect(result.formattedRut, '76.354.771-K');
      expect(result.error, isNull);
    });
  });

  group('RutValidator - TextFormField Validator', () {
    test('retorna null para RUT válido', () {
      final error = RutValidator.formFieldValidator('76354771-K');
      expect(error, isNull);
    });

    test('retorna mensaje de error para RUT inválido', () {
      final error = RutValidator.formFieldValidator('12345678-0');
      expect(error, isNotNull);
      expect(error, isNotEmpty);
    });

    test('retorna mensaje para RUT vacío', () {
      final error = RutValidator.formFieldValidator('');
      expect(error, isNotNull);
    });

    test('retorna mensaje para RUT null', () {
      final error = RutValidator.formFieldValidator(null);
      expect(error, isNotNull);
    });
  });
}