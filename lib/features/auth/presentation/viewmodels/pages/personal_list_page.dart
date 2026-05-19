import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../personal_viewmodel.dart";
import "profile_form_page.dart";

class PersonalListPage extends StatelessWidget {
  const PersonalListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final temaActual = Theme.of(context);
    final viewModel = context.watch<PersonalViewModel>();
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
                  Icon(Icons.group_off_outlined, size: 80, color: temaActual.colorScheme.primary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    "No hay trabajadores registrados",
                    style: TextStyle(fontSize: 18, color: temaActual.textTheme.bodyLarge?.color?.withOpacity(0.7)),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: temaActual.colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileFormPage()),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text("Nuevo Usuario", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}