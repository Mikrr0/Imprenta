import "dart:async";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../../core/theme/theme_provider.dart";
import "login_page.dart";
import "personal_list_page.dart";
import "profile_form_page.dart";

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
    if (!puedeMarcarAsistencia) {
      return;
    }

    setState(() {
      estadoAsistenciaActiva = !estadoAsistenciaActiva;
      segundosRestantesParaMarcar = 120;
    });

    temporizadorMarcaje?.cancel();
    temporizadorMarcaje = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (segundosRestantesParaMarcar <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() => segundosRestantesParaMarcar = 0);
        }
      } else if (mounted) {
        setState(() => segundosRestantesParaMarcar--);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              simuladorConexionInternetActivo
                  ? Icons.cloud_done
                  : Icons.cloud_off,
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
        backgroundColor: simuladorConexionInternetActivo
            ? Colors.green
            : Colors.orange.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final temaActual = Theme.of(context);
    final gestorDeTema = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard Imprenta",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              gestorDeTema.esModoOscuro ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            tooltip: "Alternar tema",
            onPressed: () {
              gestorDeTema.alternarTema();
            },
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
                onChanged: (nuevoEstado) {
                  setState(() => simuladorConexionInternetActivo = nuevoEstado);
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Cerrar sesion",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
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
                leading: CircleAvatar(
                  backgroundColor: temaActual.colorScheme.primary,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  "Bernardo Arenas",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: temaActual.textTheme.bodyLarge?.color,
                  ),
                ),
                subtitle: Text(
                  "Rol: Administrador",
                  style: TextStyle(
                    color: temaActual.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: puedeMarcarAsistencia ? marcarAsistencia : null,
                icon: Icon(
                  puedeMarcarAsistencia
                      ? (estadoAsistenciaActiva
                            ? Icons.exit_to_app
                            : Icons.access_time)
                      : Icons.timer,
                  color: Colors.white,
                ),
                label: Text(
                  puedeMarcarAsistencia
                      ? (estadoAsistenciaActiva
                            ? "MARCAR SALIDA"
                            : "MARCAR ENTRADA")
                      : "ESPERE $segundosRestantesParaMarcar SEGUNDOS",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.grey,
                  backgroundColor: estadoAsistenciaActiva
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
                children: [
                  _construirTarjetaModulo(
                    context,
                    Icons.assignment,
                    "Ordenes de\nTrabajo",
                  ),
                  _construirTarjetaModulo(
                    context,
                    Icons.inventory,
                    "Inventario",
                  ),
                  _construirTarjetaModulo(
                    context,
                    Icons.person_add,
                    "Crear\nPerfil",
                    accionAlPresionar: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileFormPage(),
                        ),
                      );
                    },
                  ),
                  _construirTarjetaModulo(
                    context,
                    Icons.people,
                    "Gestion de\nPersonal",
                    accionAlPresionar: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalListPage(),
                        ),
                      );
                    },
                  ),
                  _construirTarjetaModulo(context, Icons.bar_chart, "Reportes"),
                ],
              ),
            ),
          ],
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
    );
  }
}
