import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";

class RecuperarClavePage extends StatefulWidget {
  const RecuperarClavePage({super.key});

  @override
  State<RecuperarClavePage> createState() => _RecuperarClavePageState();
}

class _RecuperarClavePageState extends State<RecuperarClavePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controladorCorreo = TextEditingController();
  


  bool estaCargando = false;
  String? mensajeExitoGenerico;

  @override
  void dispose() {
    controladorCorreo.dispose();
    super.dispose();
  }


  Future<void> procesarRecuperacion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      estaCargando = true;
      mensajeExitoGenerico = null;
    });

    try {
      final correo = controladorCorreo.text.trim();
      await FirebaseAuth.instance.sendPasswordResetEmail(email: correo);
    } on FirebaseAuthException catch (e) {
      debugPrint("Log interno (no visible al usuario): Código ${e.code}");
    } catch (e) {
      debugPrint("Error general: $e");
    }

    if (mounted) {
      setState(() {
        estaCargando = false;
        mensajeExitoGenerico = "Si el correo está registrado, hemos enviado un enlace de recuperación.";
        controladorCorreo.clear();
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
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colorPrincipal.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mark_email_read_rounded,
                        size: 60,
                        color: colorPrincipal,
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

                    if (mensajeExitoGenerico != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                mensajeExitoGenerico!,
                                style: const TextStyle(
                                  color: Colors.green,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor ingresa un correo";
                        }
                        if (!value.contains("@") || !value.contains(".")) {
                          return "Ingresa un formato de correo válido";
                        }
                        return null;
                      },
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