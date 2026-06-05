import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/features/auth/presentation/viewmodels/login_viewmodel.dart'; 
// (Asegúrate de que la ruta al login_viewmodel sea la correcta en tu proyecto)

class RoleGuard extends StatefulWidget {
  final Widget child; // La pantalla que queremos proteger
  final List<String> rolesPermitidos; // Los roles que tienen la llave para entrar

  const RoleGuard({
    super.key,
    required this.child,
    required this.rolesPermitidos,
  });

  @override
  State<RoleGuard> createState() => _RoleGuardState();
}

class _RoleGuardState extends State<RoleGuard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarPermisos();
    });
  }

  void _verificarPermisos() {
    final usuario = context.read<LoginViewModel>().usuarioActual;
    
    // Si no hay usuario o su rol no está en la lista de permitidos
    if (usuario == null || !widget.rolesPermitidos.contains(usuario.rol)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.security, color: Colors.red),
              SizedBox(width: 10),
              Text('Acceso Denegado', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text('No tienes los permisos necesarios para acceder a esta sección del sistema.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el modal
                Navigator.of(context).pop(); // Expulsa al usuario a la pantalla anterior
              },
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<LoginViewModel>().usuarioActual;
    
    // Mientras expulsa al usuario, mostramos una pantalla vacía para que no vea información confidencial
    if (usuario == null || !widget.rolesPermitidos.contains(usuario.rol)) {
      return const Scaffold(body: SizedBox.shrink()); 
    }
    
    // Si tiene permiso, renderiza la pantalla normalmente
    return widget.child;
  }
}