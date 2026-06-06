// Archivo: lib/features/bodega/presentation/pages/proveedores_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/core/models/proveedor.dart';
import 'package:proyecto/features/bodega/presentation/pages/proveedor_form_page.dart';
import 'package:proyecto/features/bodega/presentation/viewmodels/bodega_viewmodel.dart';

class ProveedoresListPage extends StatelessWidget {
  const ProveedoresListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el ViewModel sin escuchar cambios de estado, solo para acceder al Stream
    final vm = context.read<BodegaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio de Proveedores', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0056b3),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Proveedor>>(
        stream: vm.proveedoresStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0056b3)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar proveedores: ${snapshot.error}',
                style: const TextStyle(color: Color(0xFFd32f2f)), // RNF5: Color de error
                textAlign: TextAlign.center,
              ),
            );
          }

          final proveedores = snapshot.data ?? [];

          if (proveedores.isEmpty) {
            return const Center(
              child: Text(
                'No hay proveedores registrados aún.\nPresiona el botón (+) para agregar uno.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: proveedores.length,
            itemBuilder: (context, index) {
              final proveedor = proveedores[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFe3f2fd), // Tono azul claro
                    child: Icon(Icons.business, color: Color(0xFF0056b3)),
                  ),
                  title: Text(
                    proveedor.nombreEmpresa,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('RUT: ${proveedor.rut}'),
                      Text('Contacto: ${proveedor.contacto}'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0056b3),
        tooltip: 'Registrar Proveedor',
        onPressed: () {
          // Navegamos al formulario de creación
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProveedorFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}