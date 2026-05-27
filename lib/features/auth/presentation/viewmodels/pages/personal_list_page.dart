import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../personal_viewmodel.dart";
import "../login_viewmodel.dart";
import "profile_form_page.dart";
import "login_page.dart";

class PersonalListPage extends StatelessWidget {
  const PersonalListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final temaActual = Theme.of(context);
    final viewModel = context.watch<PersonalViewModel>();
    
    // [BUG-03] [RF17] Validar rol del usuario logueado
    final loginViewModel = context.watch<LoginViewModel>();
    final usuarioActual = loginViewModel.usuarioActual;
    
    // Si no hay sesión válida, redirigir a login
    if (usuarioActual == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    // [BUG-03] Si es Operario, mostrar su propio perfil en modo lectura
    if (usuarioActual.rol == 'Operario') {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Mi Perfil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        body: ProfileFormPage(
          modoVisualizacion: true,
          perfilAMostrar: usuarioActual,
        ),
      );
    }
    
    // [BUG-03] Si es Jefe o Admin, mostrar lista de personal
    final trabajadores = viewModel.listaDeTrabajadoresGuardados;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: trabajadores.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off_outlined, size: 80, color: temaActual.colorScheme.primary.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    "No hay trabajadores registrados",
                    style: TextStyle(fontSize: 18, color: temaActual.textTheme.bodyLarge?.color?.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trabajadores.length,
              itemBuilder: (context, index) {
                final trabajador = trabajadores[index];
                return Card(
                  color: temaActual.colorScheme.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: temaActual.colorScheme.primary,
                      child: Text(
                        trabajador["nombre"]![0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      trabajador["nombre"]!,
                      style: TextStyle(fontWeight: FontWeight.bold, color: temaActual.textTheme.bodyLarge?.color),
                    ),
                    subtitle: Text(
                      "${trabajador["cargo"]} • RUT: ${trabajador["rut"]}",
                      style: TextStyle(color: temaActual.textTheme.bodyMedium?.color),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
      // [BUG-03] Botón de crear solo visible para Admin/Jefe
      floatingActionButton: (usuarioActual.rol == 'Administrador' || usuarioActual.rol == 'Jefe')
          ? FloatingActionButton.extended(
              backgroundColor: temaActual.colorScheme.primary,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileFormPage(modoVisualizacion: false)),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text("Nuevo Usuario", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }
}
