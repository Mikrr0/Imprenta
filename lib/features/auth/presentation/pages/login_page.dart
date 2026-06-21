import 'dart:async';
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";
import "package:proyecto/core/validators/campo_validators.dart";
import "package:proyecto/features/auth/presentation/viewmodels/login_viewmodel.dart";
import "package:proyecto/features/auth/presentation/pages/home_page.dart";
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

  LoginViewModel? _loginViewModel;

  // NUEVO: Variables para el ojito de la contraseña
  bool _mostrarContrasena = false;
  Timer? _ocultarTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginViewModel = context.read<LoginViewModel>();
  }

  @override
  void dispose() {
    _loginViewModel?.limpiarError();
    controladorRut.dispose();
    controladorContrasena.dispose();
    _ocultarTimer?.cancel(); // Cancelamos el timer si el usuario cambia de pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    final Color colorPrincipal = Theme.of(context).colorScheme.primary;
    final Color colorFondo = Theme.of(context).scaffoldBackgroundColor;
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                    Image.asset(
                      'assets/images/logo_fuentes.jfif',
                      width: 260,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Bienvenido",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: esOscuro ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Ingresa tus credenciales para continuar",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: esOscuro ? Colors.grey.shade400 : Colors.black54),
                    ),
                    const SizedBox(height: 32),
                    if (viewModel.mensajeDeErrorVisible != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
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
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
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

                    _buildInputLabel("RUT", esOscuro),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controladorRut,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9\-\.kK]'),
                        ),
                      ],
                      decoration: _buildInputDecoration(
                        hint: "12.345.678-9",
                        icon: Icons.badge_outlined,
                        colorPrincipal: colorPrincipal,
                        esOscuro: esOscuro,
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

                          final validationError = CampoValidators.validarRut(
                            value,
                          );
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
                    _buildInputLabel("Contraseña", esOscuro),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controladorContrasena,
                      obscureText: !_mostrarContrasena,
                      // --- NUEVA LÍNEA: Limpiamos el error si corrige la contraseña ---
                      onChanged: (value) =>
                          context.read<LoginViewModel>().limpiarError(),
                      decoration: _buildInputDecoration(
                        hint: "••••••••",
                        icon: Icons.lock_outline,
                        colorPrincipal: colorPrincipal,
                        esOscuro: esOscuro,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _mostrarContrasena ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _mostrarContrasena = true;
                            });
                            _ocultarTimer?.cancel();
                            _ocultarTimer = Timer(const Duration(seconds: 3), () {
                              if (mounted) {
                                setState(() {
                                  _mostrarContrasena = false;
                                });
                              }
                            });
                          },
                        )
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed:
                            viewModel.estaCargandoDatos ||
                                !CampoValidators.esRutValido(
                                  controladorRut.text,
                                )
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _errorRutInvalido = null);

                                  final accesoConcedido = await viewModel
                                      .procesarInicioDeSesion(
                                        CampoValidators.formatearRut(
                                          controladorRut.text,
                                        ),
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
                          shadowColor: colorPrincipal.withValues(alpha: 0.25),
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
                            const Icon(Icons.arrow_forward_rounded, size: 20),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String labelText, bool esOscuro) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        labelText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: esOscuro ? Colors.grey.shade300 : Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    required Color colorPrincipal,
    required bool esOscuro,
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
      hintStyle: TextStyle(color: Colors.grey.shade500),
      prefixIcon: Icon(icon, color: colorPrincipal),
      filled: true,
      fillColor: esOscuro ? const Color(0xFF1E293B) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
