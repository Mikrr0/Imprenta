import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/features/orden_trabajo/presentation/viewmodels/orden_trabajo_viewmodel.dart';
import 'package:proyecto/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:proyecto/features/auth/presentation/viewmodels/personal_viewmodel.dart';
import 'package:proyecto/core/models/perfil_trabajador.dart';
import 'package:intl/intl.dart';

class OrdenTrabajoCreatePage extends StatefulWidget {
  const OrdenTrabajoCreatePage({super.key});

  @override
  State<OrdenTrabajoCreatePage> createState() => _OrdenTrabajoCreatePageState();
}

class _OrdenTrabajoCreatePageState extends State<OrdenTrabajoCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descripcionController = TextEditingController();
  
  DateTime? _fechaEntregaSeleccionada;
  String _prioridadSeleccionada = 'Media';
  String? _operarioIdSeleccionado;

  @override
  void initState() {
    super.initState();
    // Asegurarnos de que la lista de trabajadores esté cargada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonalViewModel>().iniciarEscuchaTrabajadores();
    });
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? seleccion = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (seleccion != null && seleccion != _fechaEntregaSeleccionada) {
      setState(() {
        _fechaEntregaSeleccionada = seleccion;
      });
    }
  }

  Future<void> _guardarOrden() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_fechaEntregaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una fecha de entrega')),
      );
      return;
    }

    if (_operarioIdSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un operario')),
      );
      return;
    }

    final loginVM = context.read<LoginViewModel>();
    final userRole = loginVM.usuarioActual?.cargo ?? loginVM.usuarioActual?.rol ?? 'Desconocido';

    final exito = await context.read<OrdenTrabajoViewModel>().crearOrden(
      descripcion: _descripcionController.text.trim(),
      fechaEntrega: _fechaEntregaSeleccionada!,
      prioridad: _prioridadSeleccionada,
      operarioId: _operarioIdSeleccionado!,
      userRole: userRole,
    );

    if (exito && mounted) {
      Navigator.pop(context); // Volver a la lista al terminar
    } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<OrdenTrabajoViewModel>().mensajeDeErrorVisible ?? 'Error desconocido'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final personalVM = context.watch<PersonalViewModel>();
    final ordenVM = context.watch<OrdenTrabajoViewModel>();
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    // Filtrar solo los trabajadores activos que sean "Operario" (por cargo o rol)
    final operarios = personalVM.listaTrabajadores.where((t) {
      final cargo = t.cargo.toLowerCase();
      final rol = t.rol.toLowerCase();
      return cargo.contains('operario') || rol.contains('operario');
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        title: const Text('Crear Orden de Trabajo', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0056b3),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ordenVM.estaCreando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0056b3)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- DESCRIPCIÓN ---
                    _buildFormCard(
                      esOscuro: esOscuro,
                      child: TextFormField(
                        controller: _descripcionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Descripción detallada',
                          prefixIcon: Icon(Icons.description),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La descripción es obligatoria';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- FECHA DE ENTREGA ---
                    _buildFormCard(
                      esOscuro: esOscuro,
                      child: InkWell(
                        onTap: () => _seleccionarFecha(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: esOscuro ? Colors.grey.shade400 : Colors.black54),
                              const SizedBox(width: 12),
                              Text(
                                _fechaEntregaSeleccionada == null
                                    ? 'Seleccionar Fecha de Entrega'
                                    : 'Entrega: ${DateFormat('dd/MM/yyyy').format(_fechaEntregaSeleccionada!)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _fechaEntregaSeleccionada == null 
                                      ? (esOscuro ? Colors.grey.shade500 : Colors.black54)
                                      : (esOscuro ? Colors.white : Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- PRIORIDAD ---
                    _buildFormCard(
                      esOscuro: esOscuro,
                      child: DropdownButtonFormField<String>(
                        value: _prioridadSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Nivel de Prioridad',
                          prefixIcon: Icon(Icons.priority_high),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: ['Baja', 'Media', 'Alta'].map((String valor) {
                          return DropdownMenuItem<String>(
                            value: valor,
                            child: Text(valor),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _prioridadSeleccionada = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- OPERARIO ASIGNADO ---
                    _buildFormCard(
                      esOscuro: esOscuro,
                      child: personalVM.estaCargando
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 16),
                                  Text("Cargando operarios..."),
                                ],
                              ),
                            )
                          : DropdownButtonFormField<String>(
                              value: _operarioIdSeleccionado,
                              decoration: const InputDecoration(
                                labelText: 'Operario Asignado',
                                prefixIcon: Icon(Icons.person),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              hint: const Text('Seleccionar Operario'),
                              items: operarios.map((PerfilTrabajador operario) {
                                return DropdownMenuItem<String>(
                                  value: operario.id,
                                  child: Text(operario.nombreCompleto),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _operarioIdSeleccionado = newValue;
                                });
                              },
                              validator: (value) => value == null ? 'Selecciona un operario' : null,
                            ),
                    ),
                    
                    if (operarios.isEmpty && !personalVM.estaCargando)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'No hay operarios disponibles. Por favor, registre uno en Personal primero.',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 32),

                    // --- BOTÓN GUARDAR ---
                    ElevatedButton(
                      onPressed: _guardarOrden,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056b3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'REGISTRAR ORDEN DE TRABAJO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper para mantener el diseño de tarjeta con borde redondeado
  Widget _buildFormCard({required Widget child, required bool esOscuro}) {
    return Container(
      decoration: BoxDecoration(
        color: esOscuro ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: esOscuro ? Colors.grey.shade800 : Colors.grey.shade300),
      ),
      child: child,
    );
  }
}
