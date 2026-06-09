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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool estadoAsistenciaActiva = false;
  bool simuladorConexionInternetActivo = true;
  Timer? temporizadorMarcaje;
  int segundosRestantesParaMarcar = 0;

  bool get puedeMarcarAsistencia => segundosRestantesParaMarcar == 0;

  @override
  void dispose() {
    temporizadorMarcaje?.cancel();
    super.dispose();
  }

  void marcarAsistencia() {
    if (!puedeMarcarAsistencia) return;

    setState(() {
      estadoAsistenciaActiva = !estadoAsistenciaActiva;
      segundosRestantesParaMarcar = 120;
    });

    temporizadorMarcaje?.cancel();
    temporizadorMarcaje = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (segundosRestantesParaMarcar <= 1) {
        timer.cancel();
        if (mounted) setState(() => segundosRestantesParaMarcar = 0);
      } else if (mounted) {
        setState(() => segundosRestantesParaMarcar--);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              simuladorConexionInternetActivo ? Icons.cloud_done : Icons.cloud_off,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                simuladorConexionInternetActivo
                    ? "Marcaje sincronizado en el servidor"
                    : "Error de conexion: marcaje pendiente",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: simuladorConexionInternetActivo ? Colors.green : Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final temaActual = Theme.of(context);
    final gestorDeTema = context.watch<ThemeProvider>();
    
    final loginViewModel = context.watch<LoginViewModel>();
    final usuarioActual = loginViewModel.usuarioActual;
    
    if (usuarioActual == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Imprenta", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(gestorDeTema.esModoOscuro ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
            tooltip: "Alternar tema",
            onPressed: () => gestorDeTema.alternarTema(),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Icon(simuladorConexionInternetActivo ? Icons.wifi : Icons.wifi_off, color: Colors.white, size: 20),
              Switch(
                value: simuladorConexionInternetActivo,
                activeThumbColor: Colors.greenAccent,
                onChanged: (nuevoEstado) => setState(() => simuladorConexionInternetActivo = nuevoEstado),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Cerrar sesion",
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MyProfilePage()));
                },
                leading: CircleAvatar(
                  backgroundColor: temaActual.colorScheme.primary,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(usuarioActual.nombreCompleto, style: TextStyle(fontWeight: FontWeight.bold, color: temaActual.textTheme.bodyLarge?.color)),
                subtitle: Text("Rol: ${usuarioActual.rol} | Cargo: ${usuarioActual.cargo}", style: TextStyle(color: temaActual.textTheme.bodyMedium?.color)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: puedeMarcarAsistencia ? marcarAsistencia : null,
                icon: Icon(
                  puedeMarcarAsistencia ? (estadoAsistenciaActiva ? Icons.exit_to_app : Icons.access_time) : Icons.timer,
                  color: Colors.white,
                ),
                label: Text(
                  puedeMarcarAsistencia
                      ? (estadoAsistenciaActiva ? "MARCAR SALIDA" : "MARCAR ENTRADA")
                      : "ESPERE $segundosRestantesParaMarcar SEGUNDOS",
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.grey,
                  backgroundColor: estadoAsistenciaActiva ? Colors.redAccent : const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            Text("Modulos del Sistema", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: temaActual.textTheme.bodyLarge?.color)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0, 
                children: [
                  if (AppConfig.puedeVerOrdenesDeProduccion(usuarioActual.rol, usuarioActual.cargo))
                    _construirTarjetaModulo(
                      context, 
                      Icons.assignment, 
                      "Órdenes de\nTrabajo",
                      accionAlPresionar: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => const OrdenTrabajoListPage())
                      ),
                    ),

                  // 1. Botón Insumos (Protegido por AppConfig y RoleGuard)
                  if (AppConfig.puedeGestionarInventario(usuarioActual.rol, usuarioActual.cargo))
                    _construirTarjetaModulo(
                      context, 
                      Icons.inventory, 
                      "Insumos",
                      accionAlPresionar: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoleGuard(rolesPermitidos: ['Administrador', 'Jefe'], child: InsumosListPage()))),
                    ),

                  // 2. Botón Proveedores (Protegido para Admin y Jefe)
                  if (AppConfig.puedeGestionarInventario(usuarioActual.rol, usuarioActual.cargo))
                    _construirTarjetaModulo(
                      context, 
                      Icons.local_shipping, 
                      "Proveedores",
                      accionAlPresionar: () => Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => const RoleGuard(
                            rolesPermitidos: ['Administrador', 'Jefe'], 
                            child: ProveedoresListPage()
                          )
                        )
                      ),
                    ),

                  // 3. Botón Ingreso a Bodega (Protegido para Encargado de Bodega, Admin y Jefe)
                  if (['Administrador', 'Jefe'].contains(usuarioActual.rol) || usuarioActual.cargo == 'Encargado de Bodega')
                    _construirTarjetaModulo(
                      context, 
                      Icons.add_box, 
                      "Ingreso a\nBodega",
                      accionAlPresionar: () => Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => const RoleGuard(
                            rolesPermitidos: ['Administrador', 'Jefe', 'Encargado de Bodega'], 
                            child: IngresoBodegaPage()
                          )
                        )
                      ),
                    ),

                  if (AppConfig.puedeVerProduccion(usuarioActual.rol, usuarioActual.cargo))
                    _construirTarjetaModulo(context, Icons.precision_manufacturing, "Producción"),

                  // 5. Botón Personal (Limpiado: el "|| rol == 'Administrador'" era redundante)
                  if (AppConfig.puedeGestionarTrabajadores(usuarioActual.rol, usuarioActual.cargo))
                    _construirTarjetaModulo(
                      context, 
                      Icons.people, 
                      "Gestión de\nPersonal",
                      accionAlPresionar: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalListPage())),
                    ),

                  if (AppConfig.puedeVerReportes(usuarioActual.rol, usuarioActual.cargo))
                    _construirTarjetaModulo(context, Icons.bar_chart, "Reportes"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirTarjetaModulo(BuildContext context, IconData icono, String tituloMenu, {VoidCallback? accionAlPresionar}) {
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
                style: TextStyle(fontWeight: FontWeight.w600, color: temaActual.textTheme.bodyLarge?.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}