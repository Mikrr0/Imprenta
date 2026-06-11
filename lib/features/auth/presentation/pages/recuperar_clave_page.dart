import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto/core/constants/app_colors.dart';
import 'package:proyecto/core/validators/campo_validators.dart';

class RecuperarClavePage extends StatefulWidget {
  const RecuperarClavePage({super.key});

  @override
  State<RecuperarClavePage> createState() => _RecuperarClavePageState();
}

class _RecuperarClavePageState extends State<RecuperarClavePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controladorCorreo = TextEditingController();
  
  bool estaCargando = false;
  @override
  void dispose() {
    controladorCorreo.dispose();
    super.dispose();
  }

  Future<void> procesarRecuperacion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      estaCargando = true;
    });

    try {
      final correo = controladorCorreo.text.trim();
      await FirebaseAuth.instance.sendPasswordResetEmail(email: correo);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Enlace de recuperación enviado con éxito."),
          backgroundColor: AppColors.success,
        ),
      );

      if (mounted) {
        setState(() {
          estaCargando = false;
          controladorCorreo.clear();
        });
        Navigator.pop(context);
      }

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensajeError = 'Ocurrió un error inesperado.';
      if (e.code == 'user-not-found') {
        mensajeError = 'El correo electrónico no existe en el sistema.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajeError),
          backgroundColor: AppColors.error,
        ),
      );
      
      setState(() {
        estaCargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error general: $e"),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() {
        estaCargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color colorPrincipal = Theme.of(context).colorScheme.primary;
    final Color colorFondo = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    

                    Center(
                      child: Image.asset(
                        'assets/images/logo_fuentes.jfif',
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Text(
                      "Recuperar Acceso",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Ingresa tu correo electrónico y te enviaremos las instrucciones para restablecer tu contraseña.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
   
                    const SizedBox(height: 32),
                    const Text(
                      "Correo Electrónico",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controladorCorreo,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "ejemplo@correo.com",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(Icons.email_outlined, color: colorPrincipal),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colorPrincipal.withValues(alpha: 0.15), width: 1.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colorPrincipal.withValues(alpha: 0.15), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colorPrincipal.withValues(alpha: 0.8), width: 1.8),
                        ),
                      ),
                      validator: (value) => CampoValidators.validarCorreo(value),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: estaCargando ? null : procesarRecuperacion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrincipal,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: colorPrincipal.withValues(alpha: 0.25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: estaCargando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                "Enviar Enlace",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}