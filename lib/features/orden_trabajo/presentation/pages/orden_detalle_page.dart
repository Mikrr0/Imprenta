import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/core/models/orden_trabajo.dart';
import 'package:proyecto/features/orden_trabajo/presentation/viewmodels/orden_trabajo_viewmodel.dart';
import 'package:intl/intl.dart';

class OrdenDetallePageWidget extends StatefulWidget {
  final OrdenTrabajo orden;

  const OrdenDetallePageWidget({super.key, required this.orden});

  @override
  State<OrdenDetallePageWidget> createState() => _OrdenDetallePageWidgetState();
}

class _OrdenDetallePageWidgetState extends State<OrdenDetallePageWidget> {
  late OrdenTrabajo ordenActual;

  @override
  void initState() {
    super.initState();
    ordenActual = widget.orden;
  }

  Color _obtenerColorEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return const Color(0xFFFFC107);
      case 'En Proceso':
        return const Color(0xFF2196F3);
      case 'Detenida':
        return const Color(0xFFFF5722);
      case 'Finalizada':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  List<String> _obtenerEstadosDisponibles(String estadoActual) {
    // Lógica de transiciones válidas según RF5
    switch (estadoActual) {
      case 'Pendiente':
        return ['En Proceso', 'Detenida'];
      case 'En Proceso':
        return ['Detenida', 'Finalizada'];
      case 'Detenida':
        return ['En Proceso'];
      case 'Finalizada':
        return []; // No se puede cambiar desde Finalizada
      default:
        return [];
    }
  }

  Future<void> _cambiarEstado(BuildContext context, String nuevoEstado) async {
    final vm = context.read<OrdenTrabajoViewModel>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: Color(0xFF0056b3)),
              const SizedBox(height: 16),
              const Text('Actualizando estado...'),
            ],
          ),
        ),
      ),
    );

    await vm.cambiarEstadoOrden(
      ordenId: ordenActual.id,
      nuevoEstado: nuevoEstado,
      versionLocal: ordenActual.version,
    );

    if (context.mounted) {
      Navigator.pop(context); // Cierra el diálogo de carga

      // Refresca la orden
      ordenActual = vm.ordenSeleccionada ?? ordenActual;
      setState(() {});

      // Muestra mensaje de éxito o error
      if (vm.mensajeDeExitoVisible != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(vm.mensajeDeExitoVisible!)),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        vm.limpiarExito();
      } else if (vm.mensajeDeErrorVisible != null) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Error de Concurrencia'),
            content: Text(vm.mensajeDeErrorVisible!),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  // Recarga la página
                  Navigator.pop(context);
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fechaCreacion = DateFormat('dd/MM/yyyy HH:mm').format(ordenActual.fechaCreacion);
    final fechaEntrega = DateFormat('dd/MM/yyyy').format(ordenActual.fechaEntrega);
    final estadosDisponibles = _obtenerEstadosDisponibles(ordenActual.estado);
    final colorEstado = _obtenerColorEstado(ordenActual.estado);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Orden', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0056b3),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<OrdenTrabajoViewModel>(
        builder: (context, vm, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con estado
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Orden #${ordenActual.id.substring(0, 8).toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Versión: ${ordenActual.version}',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: colorEstado,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            ordenActual.estado,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Información de la orden
                Text(
                  'Información de la Orden',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _construirFilaInfo('Descripción', ordenActual.descripcion),
                _construirFilaInfo('Prioridad', ordenActual.prioridad),
                _construirFilaInfo('Operario ID', ordenActual.operarioId),
                _construirFilaInfo('Fecha Creación', fechaCreacion),
                _construirFilaInfo('Fecha Entrega', fechaEntrega),

                const SizedBox(height: 32),

                // Mensajes (éxito/error)
                if (vm.mensajeDeErrorVisible != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFd32f2f).withOpacity(0.1),
                      border: Border.all(color: const Color(0xFFd32f2f)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Color(0xFFd32f2f)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            vm.mensajeDeErrorVisible!,
                            style: const TextStyle(color: Color(0xFFd32f2f), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (vm.mensajeDeExitoVisible != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            vm.mensajeDeExitoVisible!,
                            style: const TextStyle(color: Colors.green, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Botones de cambio de estado
                if (estadosDisponibles.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.lock, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          'Orden ${ordenActual.estado}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          'No se puede modificar esta orden',
                          style: TextStyle(fontSize: 12, color: Colors.black38),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cambiar Estado',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      ...estadosDisponibles.map((estado) {
                        final colorBoton = _obtenerColorEstado(estado);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: vm.estaCambiandoEstado
                                  ? null
                                  : () => _cambiarEstado(context, estado),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorBoton,
                                disabledBackgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Cambiar a: $estado',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _construirFilaInfo(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              etiqueta,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
