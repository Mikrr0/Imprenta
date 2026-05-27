import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../../core/theme/theme_provider.dart";
import "../../../../../core/constants/app_config.dart";
import "login_page.dart";
import "personal_list_page.dart";
import "../login_viewmodel.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool estadoAsistenciaActiva = false;
  bool simuladorConexionInternetActivo = true; 

  @override
  Widget build(BuildContext context) {
    final temaActual = Theme.of(context);
    final gestorDeTema = context.watch<ThemeProvider>();
    
    // [BUG-05] Consumir ViewModel para obtener usuario real autenticado
    final loginViewModel = context.watch<LoginViewModel>();
    final usuarioActual = loginViewModel.usuarioActual;
    
    // Si no hay usuario, redirigir a login (sesión expirada/inválida)
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
            tooltip: "Alternar Tema",
            onPressed: () {
              gestorDeTema.alternarTema();
            },
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Icon(simuladorConexionInternetActivo ? Icons.wifi : Icons.wifi_off, color: Colors.white, size: 20),
              Switch(
                value: simuladorConexionInternetActivo,
                activeColor: Colors.greenAccent,
                onChanged: (nuevoEstado) {
                  setState(() => simuladorConexionInternetActivo = nuevoEstado);
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Cerrar Sesión",
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [BUG-05] Mostrar datos dinámicos del usuario autenticado desde Firebase
            Card(
              color: temaActual.colorScheme.surface,
              child: ListTile(
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
                onPressed: () {
                  setState(() => estadoAsistenciaActiva = !estadoAsistenciaActiva);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(simuladorConexionInternetActivo ? Icons.cloud_done : Icons.cloud_off, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              simuladorConexionInternetActivo ? "Marcaje Sincronizado en el servidor" : "Error de conexión: Marcaje Pendiente",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: simuladorConexionInternetActivo ? Colors.green : Colors.orange.shade700,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                icon: Icon(estadoAsistenciaActiva ? Icons.exit_to_app : Icons.access_time, color: Colors.white),
                label: Text(
                  estadoAsistenciaActiva ? "MARCAR SALIDA" : "MARCAR ENTRADA", 
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: estadoAsistenciaActiva ? Colors.redAccent : const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            Text(
              "Módulos del Sistema",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: temaActual.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // [HU01] [RF4] Órdenes de Producción
                  // Jefe de Taller supervisa + Administrador para auditoría
                  if (AppConfig.puedeVerOrdenesDeProduccion(usuarioActual.rol, usuarioActual.cargo))
                    _construirTarjetaModulo(context, Icons.assignment, "Órdenes de\nTrabajo"),

                  // [HU03] [HU09] [RF7] Gestión de Inventario / Insumos
                  // Encargado de Bodega gestiona + Administrador para supervisión
                  if (AppConfig.puedeGestionarInventario(usuarioActual.rol, usuarioActual.cargo))
                    _construirTarjetaModulo(context, Icons.inventory, "Insumos"),

                  // [RF4] [RF5] [HU02] [HU06] Producción / Mis Tareas
                  // Jefe supervisa + Operarios ven tareas + Administrador monitorea
                  if (AppConfig.puedeVerProduccion(usuarioActual.rol, usuarioActual.cargo))
                    _construirTarjetaModulo(context, Icons.precision_manufacturing, "Producción"),

                  // [RF14-a] [HU12] Gestión de Trabajadores / Perfiles (STRICT)
                  // SOLO Administrador con cargo Administrador puede entrar
                  if (AppConfig.puedeGestionarTrabajadores(usuarioActual.rol, usuarioActual.cargo))
                    _construirTarjetaModulo(
                      context, 
                      Icons.people, 
                      "Gestión de\nPersonal",
                      accionAlPresionar: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalListPage()));
                      },
                    ),

                  // [RF9] [RF11] [HU14] Reportes Analíticos
                  // Cualquier Administrador (Gerente o Administrador)
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 48, color: temaActual.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              tituloMenu, 
              textAlign: TextAlign.center, 
              style: TextStyle(fontWeight: FontWeight.w600, color: temaActual.textTheme.bodyLarge?.color)
            ),
          ],
        ),
      ),
    );
  }
}