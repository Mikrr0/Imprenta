import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../viewmodels/login_viewmodel.dart";
import "login_page.dart"; // <-- Asegúrate de que esta ruta sea correcta en tu proyecto

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loginViewModel = context.watch<LoginViewModel>();
    final usuario = loginViewModel.usuarioActual;

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: Text("Error: Sesión no encontrada")),
      );
    }

    final Color colorPrincipal = const Color(0xFF4682B4);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mi Perfil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: colorPrincipal.withValues(alpha: 0.12),
              child: Icon(Icons.person, size: 50, color: colorPrincipal),
            ),
            const SizedBox(height: 20),
            Text(
              usuario.nombreCompleto,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              usuario.rut,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildInfoTile(
              icono: Icons.work_outline,
              titulo: "Cargo Oficial",
              valor: usuario.cargo,
              color: colorPrincipal,
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              icono: Icons.admin_panel_settings_outlined,
              titulo: "Rol en el Sistema",
              valor: usuario.rol,
              color: colorPrincipal,
            ),
            const SizedBox(height: 16),

            // --- INICIO SOLUCIÓN TAREA 1: CORREO ---
            _buildInfoTile(
              icono: Icons.email_outlined,
              titulo: "Correo Electrónico",
              valor: usuario.correoElectronico,
              color: colorPrincipal,
            ),
            const SizedBox(height: 40),

            // --- INICIO SOLUCIÓN TAREA 1: BOTÓN CERRAR SESIÓN ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // 1. Ejecuta la función del ViewModel
                  await loginViewModel.procesarCierreDeSesion();

                  // 2. Verifica que el widget siga activo antes de navegar
                  if (context.mounted) {
                    // 3. Redirige al Login y limpia el historial de pantallas
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Cerrar Sesión",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // --- FIN SOLUCIÓN TAREA 1 ---
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icono,
    required String titulo,
    required String valor,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: color),
          ),
          title: Text(
            titulo,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            valor,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
