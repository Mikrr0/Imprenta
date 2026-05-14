import 'package:flutter/material.dart';
import 'package:rut_validator/rut_validator.dart'; // tu package

void main() => runApp(const MaterialApp(home: RutFormPage()));

class RutFormPage extends StatefulWidget {
  const RutFormPage({super.key});
  @override
  State<RutFormPage> createState() => _RutFormPageState();
}

class _RutFormPageState extends State<RutFormPage> {
  final _controller = TextEditingController();
  String? _mensaje;
  bool? _esValido;

  void _validar() {
    final rut = _controller.text.trim();
    final valido = RutValidator.validate(rut);
    setState(() {
      _esValido = valido;
      _mensaje = valido ? '✅ RUT válido' : '❌ RUT inválido';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba Validador RUT')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Ingresa un RUT',
                hintText: 'Ej: 12.345.678-9',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _validar,
              child: const Text('Validar RUT'),
            ),
            const SizedBox(height: 24),
            if (_mensaje != null)
              Text(
                _mensaje!,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _esValido! ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}