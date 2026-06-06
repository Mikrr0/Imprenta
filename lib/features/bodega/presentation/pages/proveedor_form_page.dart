// Archivo: lib/features/bodega/presentation/pages/proveedor_form_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/core/validators/campo_validators.dart';
import 'package:proyecto/features/bodega/presentation/viewmodels/bodega_viewmodel.dart';

class ProveedorFormPage extends StatefulWidget {
  const ProveedorFormPage({super.key});

  @override
  State<ProveedorFormPage> createState() => _ProveedorFormPageState();
}

class _ProveedorFormPageState extends State<ProveedorFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _contactoController = TextEditingController();

  @override
  void dispose() {
    _rutController.dispose();
    _nombreController.dispose();
    _contactoController.dispose();
    super.dispose();
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<BodegaViewModel>();
    
    // Eliminamos el foco del teclado al guardar
    FocusScope.of(context).unfocus();

    final exito = await vm.registrarProveedor(
      rut: _rutController.text.trim(),
      nombreEmpresa: _nombreController.text.trim(),
      contacto: _contactoController.text.trim(),
    );

    // Protección de ciclo de vida
    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proveedor registrado con éxito'), 
          backgroundColor: Colors.green, // RNF12: Feedback visual de éxito
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.mensajeError ?? 'Error al registrar proveedor'), 
          backgroundColor: const Color(0xFFd32f2f), // RNF5: Feedback de error (Rojo)
        ),
      );
      vm.limpiarError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BodegaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Proveedor', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0056b3),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- CAMPO RUT (Usando tu CampoValidators) ---
              TextFormField(
                controller: _rutController,
                decoration: const InputDecoration(
                  labelText: 'RUT de la Empresa',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                  hintText: '12.345.678-9',
                ),
                onChanged: (value) {
                  // Formateo dinámico mientras el usuario escribe
                  final formatted = CampoValidators.formatearRut(value);
                  if (formatted != value) {
                    _rutController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
                validator: CampoValidators.validarRut,
              ),
              const SizedBox(height: 16),

              // --- CAMPO NOMBRE EMPRESA ---
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Razón Social / Nombre Empresa',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre de la empresa es obligatorio';
                  }
                  if (value.trim().length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- CAMPO CONTACTO ---
              TextFormField(
                controller: _contactoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono o Correo de Contacto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.contact_phone),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El dato de contacto es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // --- BOTÓN GUARDAR ---
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: vm.estaCargando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056b3),
                  ),
                  child: vm.estaCargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'REGISTRAR PROVEEDOR', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}