import "dart:async";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../core/theme/theme_provider.dart";
import "../../../../core/constants/app_config.dart";
import "login_page.dart";
import "personal_list_page.dart";
import "../viewmodels/login_viewmodel.dart";
import "my_profile_page.dart";
import '../../../../core/guards/role_guard.dart';
import '../../../insumos/presentation/pages/insumos_list_page.dart';
import 'package:proyecto/features/bodega/presentation/pages/proveedores_list_page.dart';
import 'package:proyecto/features/bodega/presentation/pages/ingreso_bodega_page.dart';
import 'package:proyecto/features/orden_trabajo/presentation/pages/orden_trabajo_list_page.dart';
// IMPORTACIÓN NUEVA
import '../viewmodels/asistencia_viewmodel.dart';
import 'package:proyecto/features/notificaciones/presentation/viewmodels/notificacion_viewmodel.dart';
import 'package:proyecto/features/notificaciones/presentation/pages/notificaciones_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool simuladorConexionInternetActivo = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginVM = context.read<LoginViewModel>();
      final rol = loginVM.usuarioActual?.cargo ?? loginVM.usuarioActual?.rol ?? '';
      context.read<NotificacionViewModel>().iniciarEscucha(rol);
      
      final rut = loginVM.usuarioActual?.rut ?? '';
      if (rut.isNotEmpty) {
        context.read<AsistenciaViewModel>().cargarEstado(rut);
      }
    });
  }

  // --- FUNCIÓN INTEGRADA ---
  void marcarAsistencia() async {
    final loginViewModel = context.read<LoginViewModel>();
    final usuarioActual = loginViewModel.usuarioActual;
    if (usuarioActual == null) return;

    // Llamada al nuevo ViewModel persistente
    final asistenciaViewModel = context.read<AsistenciaViewModel>();
    final exito = await asistenciaViewModel.registrarAsistencia(
      usuarioActual.rut,
      usuarioActual.nombreCompleto,
    );

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Marcaje exitoso"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error de conexión"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final temaActual = Theme.of(context);
    final gestorDeTema = context.watch<ThemeProvider>();
    final loginViewModel = context.watch<LoginViewModel>();
    final usuarioActual = loginViewModel.usuarioActual;

    // ESTADO GLOBAL (NUEVO)
    final asistenciaViewModel = context.watch<AsistenciaViewModel>();
    final puedeMarcar = asistenciaViewModel.puedeMarcarAsistencia;
    final estadoActivo = asistenciaViewModel.estadoAsistenciaActiva;
    final segundosRestantes = asistenciaViewModel.segundosRestantesParaMarcar;

    final estaProcesando = asistenciaViewModel.estaProcesando;

    if (usuarioActual == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
      appBar: AppBar(
        title: const Text(
          "Imprenta Fuentes",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              gestorDeTema.esModoOscuro ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            tooltip: "Alternar tema",
            onPressed: () => gestorDeTema.alternarTema(),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Icon(
                simuladorConexionInternetActivo ? Icons.wifi : Icons.wifi_off,
                color: Colors.white,
                size: 20,
              ),
              Switch(
                value: simuladorConexionInternetActivo,
                activeThumbColor: Colors.greenAccent,
                onChanged: (nuevoEstado) => setState(
                  () => simuladorConexionInternetActivo = nuevoEstado,
                ),
              ),
            ],
          ),
          
          // CAMPANA DE NOTIFICACIONES (Solo para Jefes o Admin)
          if (usuarioActual.rol == 'Jefe' || usuarioActual.rol == 'Administrador' || usuarioActual.cargo == 'Jefe' || usuarioActual.cargo == 'Administrador')
            Consumer<NotificacionViewModel>(
              builder: (context, notificacionVM, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.white),
                      tooltip: "Notificaciones",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificacionesListPage()),
                        );
                      },
                    ),
                    if (notificacionVM.unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${notificacionVM.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: temaActual.colorScheme.surface,
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyProfilePage(),
                    ),
                  );
                },
                leading: CircleAvatar(
                  backgroundColor: temaActual.colorScheme.primary,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  usuarioActual.nombreCompleto,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: temaActual.textTheme.bodyLarge?.color,
                  ),
                ),
                subtitle: Text(
                  "Rol: ${usuarioActual.rol} | Cargo: ${usuarioActual.cargo}",
                  style: TextStyle(
                    color: temaActual.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // BOTÓN INTEGRADO CON EL ESTADO GLOBAL
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: (puedeMarcar && !estaProcesando) ? marcarAsistencia : null,
                icon: estaProcesando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(
                        puedeMarcar
                            ? (estadoActivo ? Icons.exit_to_app : Icons.access_time)
                            : Icons.timer,
                        color: Colors.white,
                      ),
                label: Text(
                  estaProcesando 
                      ? "PROCESANDO..."
                      : puedeMarcar
                          ? (estadoActivo ? "MARCAR SALIDA" : "MARCAR ENTRADA")
                          : "ESPERE $segundosRestantes SEGUNDOS",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.grey,
                  backgroundColor: estadoActivo
                      ? Colors.redAccent
                      : const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Modulos del Sistema",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: temaActual.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  if (AppConfig.puedeVerOrdenesDeProduccion(
                    usuarioActual.rol,
                    usuarioActual.cargo,
                  ))
                    _construirTarjetaModulo(
                      context,
                      Icons.assignment,
                      "Órdenes de\nTrabajo",
                      accionAlPresionar: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OrdenTrabajoListPage(),
                        ),
                      ),
                    ),

                  if (AppConfig.puedeGestionarInventario(
                    usuarioActual.rol,
                    usuarioActual.cargo,
                  ))
                    _construirTarjetaModulo(
                      context,
                      Icons.inventory,
                      "Insumos",
                      accionAlPresionar: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoleGuard(
                            rolesPermitidos: ['Administrador', 'Jefe'],
                            child: InsumosListPage(),
                          ),
                        ),
                      ),
                    ),

                  if (AppConfig.puedeGestionarInventario(
                    usuarioActual.rol,
                    usuarioActual.cargo,
                  ))
                    _construirTarjetaModulo(
                      context,
                      Icons.local_shipping,
                      "Proveedores",
                      accionAlPresionar: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoleGuard(
                            rolesPermitidos: ['Administrador', 'Jefe'],
                            child: ProveedoresListPage(),
                          ),
                        ),
                      ),
                    ),

                  if (['Administrador', 'Jefe'].contains(usuarioActual.rol) ||
                      usuarioActual.cargo == 'Encargado de Bodega')
                    _construirTarjetaModulo(
                      context,
                      Icons.add_box,
                      "Ingreso a\nBodega",
                      accionAlPresionar: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoleGuard(
                            rolesPermitidos: [
                              'Administrador',
                              'Jefe',
                              'Encargado de Bodega',
                            ],
                            child: const IngresoBodegaPage(),
                          ),
                        ),
                      ),
                    ),



                  if (AppConfig.puedeGestionarTrabajadores(
                    usuarioActual.rol,
                    usuarioActual.cargo,
                  ))
                    _construirTarjetaModulo(
                      context,
                      Icons.people,
                      "Gestión de\nPersonal",
                      accionAlPresionar: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PersonalListPage(),
                        ),
                      ),
                    ),

                  if (AppConfig.puedeVerReportes(
                    usuarioActual.rol,
                    usuarioActual.cargo,
                  ))
                    _construirTarjetaModulo(
                      context,
                      Icons.bar_chart,
                      "Reportes",
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _construirTarjetaModulo(
    BuildContext context,
    IconData icono,
    String tituloMenu, {
    VoidCallback? accionAlPresionar,
  }) {
    final temaActual = Theme.of(context);
    return Card(
      color: temaActual.colorScheme.surface,
      child: InkWell(
        onTap: accionAlPresionar,
        child: Container(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 48, color: temaActual.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                tituloMenu,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: temaActual.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
