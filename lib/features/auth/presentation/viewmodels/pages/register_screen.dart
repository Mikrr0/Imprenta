import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/features/auth/presentation/viewmodels/login_viewmodel.dart'; // <-- Ajusta esta ruta si es necesario

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rutController = TextEditingController();
  final _nombreController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _rutController.dispose();
    _nombreController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _registrarUsuario() async {
    // Validamos que los campos no estén vacíos
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<LoginViewModel>();
      
      // Ocultar el teclado
      FocusScope.of(context).unfocus();

      final exito = await viewModel.crearCuenta(
        _rutController.text,
        _passwordController.text,
        _nombreController.text,
      );

      // Si el widget ya no está en pantalla, no hacemos nada
      if (!mounted) return;

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Trabajador registrado con éxito!"),
            backgroundColor: Colors.green,
          ),
        );
        // Volvemos a la pantalla de Login automáticamente
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.mensajeDeErrorVisible ?? "Error al registrar"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el ViewModel para saber si está cargando
    final estaRegistrando = context.watch<LoginViewModel>().estaRegistrando;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Trabajador"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person_add_alt_1, size: 80, color: Colors.blue),
                const SizedBox(height: 32),
                
                // --- CAMPO RUT ---
                TextFormField(
                  controller: _rutController,
                  decoration: const InputDecoration(
                    labelText: "RUT (Ej: 12345678-9)",
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Ingrese el RUT" : null,
                ),
                const SizedBox(height: 16),

                // --- CAMPO NOMBRE ---
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: "Nombre Completo",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Ingrese el nombre" : null,
                ),
                const SizedBox(height: 16),

                // --- CAMPO CONTRASEÑA ---
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña temporal",
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.length < 6 
                      ? "Debe tener al menos 6 caracteres" 
                      : null,
                ),
                const SizedBox(height: 32),

                // --- BOTÓN DE REGISTRO ---
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: estaRegistrando ? null : _registrarUsuario,
                    child: estaRegistrando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Guardar en Base de Datos", 
                            style: TextStyle(fontSize: 16)
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}