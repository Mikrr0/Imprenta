import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";
import "package:proyecto/core/validators/campo_validators.dart";
import "package:proyecto/features/auth/presentation/viewmodels/login_viewmodel.dart";
import "package:proyecto/features/auth/presentation/viewmodels/pages/home_page.dart";
import "recuperar_clave_page.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controladorRut = TextEditingController();
  final TextEditingController controladorContrasena = TextEditingController();


  String? _errorRutInvalido;

  @override
  void dispose() {
    controladorRut.dispose();
    controladorContrasena.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    final Color colorPrincipal = Theme.of(context).colorScheme.primary;
    final Color colorFondo = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: colorFondo,
      body: Align(
        alignment: const Alignment(0, -0.4),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colorPrincipal.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_printshop_rounded,
                      size: 60,
                      color: colorPrincipal,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "IMPRENTA",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: colorPrincipal,
                      letterSpacing: 5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Bienvenido",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Ingresa tus credenciales para continuar",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (viewModel.mensajeDeErrorVisible != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              viewModel.mensajeDeErrorVisible!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  if (_errorRutInvalido != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorRutInvalido!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  _buildInputLabel("RUT"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controladorRut,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\.kK]')),
                    ],
                    decoration: _buildInputDecoration(
                      hint: "12.345.678-9",
                      icon: Icons.badge_outlined,
                      colorPrincipal: colorPrincipal,
                    ),
                    validator: CampoValidators.validarRut,
                    onChanged: (value) {
                      context.read<LoginViewModel>().limpiarError();
                      if (value.isNotEmpty) {
                        final formatted = CampoValidators.formatearRut(value);
                        if (formatted != value) {
                          controladorRut.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.fromPosition(
                              TextPosition(offset: formatted.length),
                            ),
                          );
                        }
                        
                        final validationError = CampoValidators.validarRut(value);
                        setState(() {
                          _errorRutInvalido = validationError;
                        });
                      } else {
                        setState(() {
                          _errorRutInvalido = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildInputLabel("Contraseña"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controladorContrasena,
                    obscureText: true,
                    // --- NUEVA LÍNEA: Limpiamos el error si corrige la contraseña ---
                    onChanged: (value) => context.read<LoginViewModel>().limpiarError(),
                    decoration: _buildInputDecoration(
                      hint: "••••••••",
                      icon: Icons.lock_outline,
                      colorPrincipal: colorPrincipal,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: viewModel.estaCargandoDatos || !CampoValidators.esRutValido(controladorRut.text)
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _errorRutInvalido = null);
                                
                                final accesoConcedido = await viewModel
                                    .procesarInicioDeSesion(
                                  CampoValidators.formatearRut(controladorRut.text),
                                  controladorContrasena.text,
                                );

                                if (accesoConcedido && context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const HomePage(),
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrincipal,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: colorPrincipal.withOpacity(0.25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          viewModel.estaCargandoDatos
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Iniciar Sesión",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecuperarClavePage(),
                        ),
                      );
                    },
                    child: Text(
                      "¿Olvidaste tu contraseña?",
                      style: TextStyle(
                      color: colorPrincipal,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      ),
                    ),
                  )
                ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String labelText) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        labelText,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    required Color colorPrincipal,
  }) {
    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: colorPrincipal.withValues(alpha: 0.15),
        width: 1.2,
      ),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
      ),
      prefixIcon: Icon(
        icon,
        color: colorPrincipal,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: borderStyle,
      enabledBorder: borderStyle,
      focusedBorder: borderStyle.copyWith(
        borderSide: BorderSide(
          color: colorPrincipal.withValues(alpha: 0.8),
          width: 1.8,
        ),
      ),
    );
  }
}