import 'package:flutter_test/flutter_test.dart';

import 'package:rut_validator/rut_validator.dart';

void main() {
  group('RutValidator', () {
    test('valida RUTs correctos', () {
      expect(RutValidator.validate('12345678-9'), isFalse); // ejemplo
      expect(RutValidator.validate('76354771-K'), isTrue);
      expect(RutValidator.validate('76.354.771-K'), isTrue);
    });

    test('rechaza RUTs inválidos', () {
      expect(RutValidator.validate('12345678-0'), isFalse);
      expect(RutValidator.validate(''), isFalse);
      expect(RutValidator.validate('abc'), isFalse);
    });

    test('formatea correctamente', () {
      expect(RutValidator.format('76354771K'), '76.354.771-K');
    });
  });
}