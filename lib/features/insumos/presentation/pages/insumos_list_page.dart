// Archivo: lib/features/insumos/presentation/pages/insumos_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/features/insumos/presentation/viewmodels/insumo_viewmodel.dart';
import 'package:proyecto/features/insumos/presentation/pages/insumos_form_page.dart';

class InsumosListPage extends StatefulWidget {
  const InsumosListPage({super.key});

  @override
  State<InsumosListPage> createState() => _InsumosListPageState();
}

class _InsumosListPageState extends State<InsumosListPage> {
  @override
  void initState() {
    super.initState();
    // Iniciamos la escucha reactiva del catálogo apenas carga la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsumoViewModel>().iniciarEscuchaInsumos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Insumos', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0056b3), // Azul semántico (RNF7)
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<InsumoViewModel>(
        builder: (context, vm, child) {
          // 1. Estado de Carga
          if (vm.estaCargando && vm.listaInsumos.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0056b3)));
          }

          // 2. Estado de Error
          if (vm.mensajeDeErrorVisible != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  vm.mensajeDeErrorVisible!,
                  style: const TextStyle(color: Color(0xFFd32f2f), fontSize: 16), // Rojo (RNF7)
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // 3. Estado Vacío
          if (vm.listaInsumos.isEmpty) {
            return const Center(
              child: Text(
                'El catálogo está vacío.\nPresiona el botón + para registrar un insumo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          // 4. Lista de Insumos
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: vm.listaInsumos.length,
            itemBuilder: (context, index) {
              final insumo = vm.listaInsumos[index];
              
              // Cálculo de valorización total (RF16 b)
              final valorizacion = insumo.stock * insumo.precioUnitario;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  title: Text(
                    insumo.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text('${insumo.tipoPapel} | ${insumo.gramaje} | ${insumo.tamano}'),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Stock: ${insumo.stock} unid.',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Precio: \$${insumo.precioUnitario.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Valorización Stock: \$${valorizacion.toStringAsFixed(0)}',
                        style: const TextStyle(color: Color(0xFF388E3C), fontWeight: FontWeight.bold), // Verde
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF0056b3)),
                    onPressed: () {
                      // Navegamos al formulario pasando el insumo a editar
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InsumoFormPage(insumoAEditar: insumo),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0056b3),
        onPressed: () {
          // Navegamos al formulario en modo creación (sin pasar objeto)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const InsumoFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}