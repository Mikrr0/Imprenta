import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/notificacion_viewmodel.dart';

class NotificacionesListPage extends StatelessWidget {
  const NotificacionesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notificacionVM = context.watch<NotificacionViewModel>();
    
    // FILTRO: Solo mostramos las que NO han sido leídas para quitar el ruido visual
    final notificacionesPendientes = notificacionVM.notificaciones.where((n) => !n.leida).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0056b3),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // NUEVO: Botón para limpiar toda la bandeja de una vez
          if (notificacionesPendientes.isNotEmpty)
            TextButton.icon(
              onPressed: () => notificacionVM.marcarTodasComoLeidas(),
              icon: const Icon(Icons.clear_all, color: Colors.white),
              label: const Text('Limpiar', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: notificacionesPendientes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_active_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay alertas pendientes',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notificacionesPendientes.length,
              itemBuilder: (context, index) {
                final noti = notificacionesPendientes[index];
                final tema = Theme.of(context);
                
                return Card(
                  color: tema.brightness == Brightness.dark ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.shade50,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: noti.tipoIncidencia == 'Atraso' ? Colors.orange : Colors.red,
                      child: Icon(
                        noti.tipoIncidencia == 'Atraso' ? Icons.watch_later : Icons.person_off,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      '${noti.tipoIncidencia} - ${noti.nombreTrabajador}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(noti.fechaHora),
                    ),
                    // Indicador visual de que al tocarla se quitará
                    trailing: const Icon(Icons.check_circle_outline, color: Colors.blue),
                    onTap: () {
                      // Al marcarla como leída, la base de datos se actualiza y la notificación desaparece de la vista automáticamente
                      context.read<NotificacionViewModel>().marcarComoLeida(noti.id);
                    },
                  ),
                );
              },
            ),
    );
  }
}