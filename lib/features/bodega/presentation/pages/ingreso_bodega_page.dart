// Archivo: lib/features/bodega/presentation/pages/ingreso_bodega_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/core/models/insumo.dart';
import 'package:proyecto/core/models/proveedor.dart';
import 'package:proyecto/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:proyecto/features/bodega/presentation/viewmodels/bodega_viewmodel.dart';
import 'package:proyecto/features/insumos/presentation/viewmodels/insumo_viewmodel.dart';

class IngresoBodegaPage extends StatefulWidget {
  const IngresoBodegaPage({super.key});

  @override
  State<IngresoBodegaPage> createState() => _IngresoBodegaPageState();
}

class _IngresoBodegaPageState extends State<IngresoBodegaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cantidadController = TextEditingController();

  String? _selectedInsumoId;
  String? _selectedProveedorId;

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  void _registrarIngreso() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedInsumoId == null || _selectedProveedorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione un Insumo y un Proveedor.'),
          backgroundColor: Color(0xFFf9a825), // RNF5: Advertencia (Amarillo)
        ),
      );
      return;
    }

    final vmBodega = context.read<BodegaViewModel>();
    final vmAuth = context.read<LoginViewModel>();
    
    // Extracción limpia del ID del usuario desde la sesión actual
    // Usamos 'Sistema' como fallback de seguridad, aunque por tu RoleGuard siempre debería haber un ID.
    final String idBodeguero = vmAuth.usuarioActual?.id ?? 'Sistema';

    FocusScope.of(context).unfocus();

    final exito = await vmBodega.registrarIngreso(
      insumoId: _selectedInsumoId!,
      proveedorId: _selectedProveedorId!,
      cantidadStr: _cantidadController.text.trim(),
      registradoPorUid: idBodeguero, // Trazabilidad inyectada correctamente
    );

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingreso a bodega registrado y stock actualizado con éxito.'),
          backgroundColor: Colors.green, // RNF12: Éxito (Verde)
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vmBodega.mensajeError ?? 'Error al registrar el ingreso.'),
          backgroundColor: const Color(0xFFd32f2f), // RNF5: Error (Rojo)
        ),
      );
      vmBodega.limpiarError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vmBodega = context.watch<BodegaViewModel>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingreso a Bodega', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0056b3),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Complete los datos del camión o entrega para sumar el stock al inventario general.',
                style: TextStyle(fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.black54),
              ),
              const SizedBox(height: 24),

              // --- SELECTOR DE INSUMO (Catálogo) ---
              StreamBuilder<List<Insumo>>(
                stream: context.read<InsumoViewModel>().useCase.repository.obtenerInsumosStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }
                  
                  final insumos = snapshot.data ?? [];
                  
                  if (insumos.isEmpty) {
                    return Card(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.orange.withValues(alpha: 0.15) : const Color(0xFFfff3cd),
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('No hay insumos registrados en el catálogo. Vaya al módulo de Insumos primero.'),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Insumo a Ingresar',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    initialValue: _selectedInsumoId,
                    items: insumos.map((insumo) {
                      return DropdownMenuItem(
                        value: insumo.id,
                        child: Text('${insumo.nombre} (${insumo.tipoPapel} - ${insumo.gramaje})'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedInsumoId = val),
                  );
                },
              ),
              const SizedBox(height: 16),

              // --- SELECTOR DE PROVEEDOR ---
              StreamBuilder<List<Proveedor>>(
                stream: vmBodega.proveedoresStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }
                  
                  final proveedores = snapshot.data ?? [];

                  if (proveedores.isEmpty) {
                    return Card(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.orange.withValues(alpha: 0.15) : const Color(0xFFfff3cd),
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('No hay proveedores registrados. Debe registrar al menos uno antes de ingresar stock.'),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Proveedor',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_shipping),
                    ),
                    initialValue: _selectedProveedorId,
                    items: proveedores.map((prov) {
                      return DropdownMenuItem(
                        value: prov.id,
                        child: Text(prov.nombreEmpresa),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedProveedorId = val),
                  );
                },
              ),
              const SizedBox(height: 16),

              // --- CAMPO CANTIDAD (RNF14: Validación estricta) ---
              TextFormField(
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad a Ingresar (Unidades)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.add_box),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  final num = int.tryParse(value);
                  if (num == null) return 'Solo números enteros';
                  if (num <= 0) return 'La cantidad debe ser mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // --- BOTÓN REGISTRAR ---
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: vmBodega.estaCargando ? null : _registrarIngreso,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056b3),
                  ),
                  child: vmBodega.estaCargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'REGISTRAR INGRESO Y SUMAR STOCK', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}