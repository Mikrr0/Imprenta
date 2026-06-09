import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/features/orden_trabajo/presentation/viewmodels/orden_trabajo_viewmodel.dart';
import 'package:proyecto/features/orden_trabajo/presentation/pages/orden_detalle_page.dart';
import 'package:intl/intl.dart';

class OrdenTrabajoListPage extends StatefulWidget {
  const OrdenTrabajoListPage({super.key});

  @override
  State<OrdenTrabajoListPage> createState() => _OrdenTrabajoListPageState();
}

class _OrdenTrabajoListPageState extends State<OrdenTrabajoListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdenTrabajoViewModel>().iniciarEscuchaOrdenes();
    });
  }

  Color _obtenerColorEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return const Color(0xFFFFC107); // Amarillo
      case 'En Proceso':
        return const Color(0xFF2196F3); // Azul
      case 'Detenida':
        return const Color(0xFFFF5722); // Naranja
      case 'Finalizada':
        return const Color(0xFF4CAF50); // Verde
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes de Trabajo', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0056b3),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<OrdenTrabajoViewModel>(
        builder: (context, vm, child) {
          // 1. Estado de Carga
          if (vm.estaCargando && vm.listaOrdenes.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0056b3)),
            );
          }

          // 2. Estado de Error
          if (vm.mensajeDeErrorVisible != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Color(0xFFd32f2f), size: 64),
                    const SizedBox(height: 16),
                    Text(
                      vm.mensajeDeErrorVisible!,
                      style: const TextStyle(color: Color(0xFFd32f2f), fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => vm.iniciarEscuchaOrdenes(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Estado Vacío
          if (vm.listaOrdenes.isEmpty) {
            return const Center(
              child: Text(
                'No hay órdenes de trabajo.\nPresiona el botón + para crear una nueva.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          // 4. Lista de Órdenes
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: vm.listaOrdenes.length,
            itemBuilder: (context, index) {
              final orden = vm.listaOrdenes[index];
              final colorEstado = _obtenerColorEstado(orden.estado);
              final fechaFormato = DateFormat('dd/MM/yyyy').format(orden.fechaEntrega);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: InkWell(
                  onTap: () async {
                    await vm.seleccionarOrden(orden.id);
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrdenDetallePageWidget(orden: orden),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Orden #${orden.id.substring(0, 8).toUpperCase()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: colorEstado,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                orden.estado,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Descripción: ${orden.descripcion}',
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Prioridad: ${orden.prioridad}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: orden.prioridad == 'Alta'
                                    ? const Color(0xFFd32f2f)
                                    : orden.prioridad == 'Media'
                                        ? const Color(0xFFFFC107)
                                        : Colors.green,
                              ),
                            ),
                            Text(
                              'Entrega: $fechaFormato',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
