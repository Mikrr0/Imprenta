import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../viewmodels/personal_viewmodel.dart"; 
import "../viewmodels/login_viewmodel.dart";    
import "profile_form_page.dart";
import "login_page.dart";
import "package:proyecto/core/guards/role_guard.dart"; 

class PersonalListPage extends StatefulWidget {
  const PersonalListPage({super.key});

  @override
  State<PersonalListPage> createState() => _PersonalListPageState();
}

class _PersonalListPageState extends State<PersonalListPage> {
  bool _mostrarActivos = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonalViewModel>().iniciarEscuchaTrabajadores();
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
    
    return RoleGuard(
      rolesPermitidos: const ['Administrador', 'Jefe'],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Personal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: "Actualizar lista",
              onPressed: () => viewModel.iniciarEscuchaTrabajadores(),
            ),
          ],
          elevation: 0,
        ),
        body: viewModel.estaCargando
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('Activos'),
                            icon: Icon(Icons.check_circle_outline),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('Inactivos'),
                            icon: Icon(Icons.person_off_outlined),
                          ),
                        ],
                        selected: {_mostrarActivos},
                        onSelectionChanged: (Set<bool> nuevaSeleccion) {
                          setState(() {
                            // Actualizamos la vista al hacer clic
                            _mostrarActivos = nuevaSeleccion.first;
                          });
                        },
                        style: SegmentedButton.styleFrom(
                          selectedForegroundColor: Colors.white,
                          selectedBackgroundColor: temaActual.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: _construirLista(
                      context: context, 
                      temaActual: temaActual, 
                      lista: _mostrarActivos ? viewModel.listaTrabajadores : viewModel.listaTrabajadoresInactivos, 
                      usuarioActual: usuarioActual, 
                      viewModel: viewModel, 
                      esActivo: _mostrarActivos
                    ),
                  ),
                ],
              ),
        
        floatingActionButton: (usuarioActual.rol == 'Administrador' || usuarioActual.rol == 'Jefe')
            ? FloatingActionButton.extended(
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
              )
            : null,
      ),
    );
  }
  Widget _construirLista({
    required BuildContext context, 
    required ThemeData temaActual, 
    required List lista, 
    required dynamic usuarioActual, 
    required PersonalViewModel viewModel,
    required bool esActivo
  }) {
    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(esActivo ? Icons.group_off_outlined : Icons.person_off_outlined, 
                size: 80, color: temaActual.colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              esActivo ? "No hay trabajadores registrados" : "La lista está vacía",
              style: TextStyle(fontSize: 18, color: temaActual.textTheme.bodyLarge?.color?.withValues(alpha: 0.7)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 80),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final trabajador = lista[index];
        
        if (trabajador.rut == usuarioActual.rut) {
          return const SizedBox.shrink(); 
        }
        
        return Card(
          elevation: 2,
          color: temaActual.colorScheme.surface,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: esActivo ? temaActual.colorScheme.primary : Colors.grey.shade400,
              child: Text(
                trabajador.nombreCompleto.isNotEmpty ? trabajador.nombreCompleto[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              trabajador.nombreCompleto,
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: esActivo ? temaActual.textTheme.bodyLarge?.color : Colors.grey.shade600
              ),
            ),
            subtitle: Text(
              "${trabajador.cargo} • RUT: ${trabajador.rut}",
              style: TextStyle(color: temaActual.textTheme.bodyMedium?.color),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (esActivo) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileFormPage(
                            modoVisualizacion: false,
                            perfilAMostrar: trabajador, 
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_off_outlined, color: Colors.red),
                    onPressed: () => _mostrarDialogoConfirmacion(context, viewModel, trabajador.id ?? ''),
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.restore, color: Colors.green),
                    tooltip: "Reactivar trabajador",
                    onPressed: () => _mostrarDialogoReactivacion(context, viewModel, trabajador.id ?? ''),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarDialogoConfirmacion(BuildContext context, PersonalViewModel vm, String id) {
    if (id.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inhabilitar Trabajador'),
        content: const Text('¿Estás seguro de que deseas inhabilitar a este trabajador? Será enviado a la sección de inactivos.'),
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
              if (!context.mounted) return;
              if (exito) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Trabajador enviado a la sección de inactivos'), backgroundColor: Colors.orange),
                );
              }
            },
            child: const Text('Inhabilitar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoReactivacion(BuildContext context, PersonalViewModel vm, String id) {
    if (id.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reactivar Trabajador'),
        content: const Text('¿Deseas restaurar a este trabajador? Volverá a la lista de activos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              Navigator.pop(ctx); 
              final exito = await vm.habilitarTrabajador(id);
              if (!context.mounted) return;
              if (exito) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Trabajador reactivado con éxito'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Reactivar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}