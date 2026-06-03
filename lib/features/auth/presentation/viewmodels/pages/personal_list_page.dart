import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../personal_viewmodel.dart"; 
import "../login_viewmodel.dart";    
import "profile_form_page.dart";
import "login_page.dart";

class PersonalListPage extends StatefulWidget {
  const PersonalListPage({super.key});

  @override
  State<PersonalListPage> createState() => _PersonalListPageState();
}

class _PersonalListPageState extends State<PersonalListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonalViewModel>().cargarTrabajadores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final temaActual = Theme.of(context);
    final viewModel = context.watch<PersonalViewModel>();
    final loginViewModel = context.watch<LoginViewModel>();
    final usuarioActual = loginViewModel.usuarioActual;
    
    if (usuarioActual == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Actualizar lista",
            onPressed: () => viewModel.cargarTrabajadores(),
          ),
        ],
      ),
      body: viewModel.estaCargando
          ? const Center(child: CircularProgressIndicator())
          : viewModel.listaTrabajadores.isEmpty
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
                  itemCount: viewModel.listaTrabajadores.length,
                  itemBuilder: (context, index) {
                    final trabajador = viewModel.listaTrabajadores[index];
                    
                    return Card(
                      color: temaActual.colorScheme.surface,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: temaActual.colorScheme.primary,
                          child: Text(
                            trabajador.nombreCompleto.isNotEmpty ? trabajador.nombreCompleto[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          trabajador.nombreCompleto,
                          style: TextStyle(fontWeight: FontWeight.bold, color: temaActual.textTheme.bodyLarge?.color),
                        ),
                        subtitle: Text(
                          "${trabajador.cargo} • RUT: ${trabajador.rut}",
                          style: TextStyle(color: temaActual.textTheme.bodyMedium?.color),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // --- BOTÓN EDITAR ---
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileFormPage(
                                      modoVisualizacion: false,
                                      perfilAMostrar: trabajador, // Le enviamos los datos para editar
                                    ),
                                  ),
                                );
                              },
                            ),
                            // --- BOTÓN ELIMINAR ---
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _mostrarDialogoConfirmacion(context, viewModel, trabajador.id ?? '');
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      
      // --- BOTÓN CREAR NUEVO USUARIO ---
      floatingActionButton: (usuarioActual.rol == 'Administrador' || usuarioActual.rol == 'Jefe')
          ? FloatingActionButton.extended(
              backgroundColor: temaActual.colorScheme.primary,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileFormPage()), // Abre vacío para crear
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text("Nuevo Usuario", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  void _mostrarDialogoConfirmacion(BuildContext context, PersonalViewModel vm, String id) {
    if (id.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Trabajador'),
        content: const Text('¿Estás seguro de que deseas borrar este registro de la base de datos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final exito = await vm.eliminarTrabajador(id);
              if (exito && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Trabajador eliminado correctamente'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}