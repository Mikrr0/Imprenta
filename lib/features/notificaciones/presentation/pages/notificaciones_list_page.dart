import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/notificacion_viewmodel.dart';

class NotificacionesListPage extends StatelessWidget {
  const NotificacionesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notificacionVM = context.watch<NotificacionViewModel>();
    final notificaciones = notificacionVM.notificaciones;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones de Hoy', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0056b3),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: notificaciones.isEmpty
          ? const Center(
              child: Text(
                'No hay notificaciones pendientes',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: notificaciones.length,
              itemBuilder: (context, index) {
                final noti = notificaciones[index];
                final isLeida = noti.leida;
                
                return Card(
                  color: isLeida ? Colors.white : Colors.blue.shade50,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: isLeida ? 1 : 3,
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
                      style: TextStyle(
                        fontWeight: isLeida ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(noti.fechaHora),
                    ),
                    trailing: isLeida 
                      ? const Icon(Icons.check, color: Colors.green)
                      : const Icon(Icons.circle, color: Colors.blue, size: 12),
                    onTap: () {
                      if (!isLeida) {
                        context.read<NotificacionViewModel>().marcarComoLeida(noti.id);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
