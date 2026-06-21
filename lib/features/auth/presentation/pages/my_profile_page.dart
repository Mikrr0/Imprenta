import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../viewmodels/login_viewmodel.dart";
import "login_page.dart";
import '../../../../core/validators/campo_validators.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loginViewModel = context.watch<LoginViewModel>();
    final usuario = loginViewModel.usuarioActual;
    final temaActual = Theme.of(context); // Extraemos el tema dinámico

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: Text("Error: Sesión no encontrada")),
      );
    }

    final Color colorPrincipal = const Color(0xFF4682B4);

    return Scaffold(
      backgroundColor: temaActual.scaffoldBackgroundColor, // Respeta el fondo oscuro/claro
      appBar: AppBar(
        title: const Text(
          "Mi Perfil",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: temaActual.textTheme.bodyLarge?.color, // Texto dinámico
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              CampoValidators.formatearRut(usuario.rut), 
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildInfoTile(
              context, // Pasamos el contexto para leer el modo oscuro
              icono: Icons.work_outline,
              titulo: "Cargo Oficial",
              valor: usuario.cargo,
              color: colorPrincipal,
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              context,
              icono: Icons.admin_panel_settings_outlined,
              titulo: "Rol en el Sistema",
              valor: usuario.rol,
              color: colorPrincipal,
            ),
            const SizedBox(height: 16),

            _buildInfoTile(
              context,
              icono: Icons.email_outlined,
              titulo: "Correo Electrónico",
              valor: usuario.correoElectronico,
              color: colorPrincipal,
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await loginViewModel.procesarCierreDeSesion();
                  if (context.mounted) {
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
          ],
        ),
      ),
    );
  }

  // Ahora recibe el BuildContext para adaptarse al tema
  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icono,
    required String titulo,
    required String valor,
    required Color color,
  }) {
    final temaActual = Theme.of(context);
    
    return Card(
      color: temaActual.cardColor, // Fondo de tarjeta dinámico
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
            style: TextStyle(
              fontSize: 13,
              color: temaActual.brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            valor,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: temaActual.textTheme.bodyLarge?.color, // Cambia mágicamente a blanco en modo oscuro
            ),
            softWrap: true, // Esto permite el salto de línea
            overflow: TextOverflow.visible, // Asegura que el texto no se corte
          ),
        ),
      ),
    );
  }
}