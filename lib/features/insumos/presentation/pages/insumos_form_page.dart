// Archivo: lib/features/insumos/presentation/pages/insumos_form_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/core/models/insumo.dart';
import 'package:proyecto/features/insumos/presentation/viewmodels/insumo_viewmodel.dart';

class InsumoFormPage extends StatefulWidget {
  final Insumo? insumoAEditar;

  const InsumoFormPage({super.key, this.insumoAEditar});

  @override
  State<InsumoFormPage> createState() => _InsumoFormPageState();
}

class _InsumoFormPageState extends State<InsumoFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores normales
  late TextEditingController _nombreController;
  late TextEditingController _stockController;
  late TextEditingController _precioController;

  // Controladores para ingresos nuevos ("Otro")
  final TextEditingController _nuevoTipoPapelController = TextEditingController();
  final TextEditingController _nuevoGramajeController = TextEditingController();
  final TextEditingController _nuevoTamanoController = TextEditingController();

  // Estados de los menús
  String? _selectedTipoPapel;
  String? _selectedGramaje;
  String? _selectedTamano;

  // Switches visuales
  bool _esNuevoTipoPapel = false;
  bool _esNuevoGramaje = false;
  bool _esNuevoTamano = false;

  bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.insumoAEditar?.nombre ?? '');
    _stockController = TextEditingController(text: widget.insumoAEditar?.stock.toString() ?? '');
    _precioController = TextEditingController(text: widget.insumoAEditar?.precioUnitario.toStringAsFixed(0) ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<InsumoViewModel>();
      await vm.cargarParametros();

      // PROTECCIÓN DE CICLO DE VIDA
      if (!mounted) return;

      if (widget.insumoAEditar != null) {
        setState(() {
          if (vm.tiposPapel.contains(widget.insumoAEditar!.tipoPapel)) {
            _selectedTipoPapel = widget.insumoAEditar!.tipoPapel;
          }
          if (vm.gramajes.contains(widget.insumoAEditar!.gramaje)) {
            _selectedGramaje = widget.insumoAEditar!.gramaje;
          }
          if (vm.tamanos.contains(widget.insumoAEditar!.tamano)) {
            _selectedTamano = widget.insumoAEditar!.tamano;
          }
        });
      }
      setState(() => _inicializado = true);
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _stockController.dispose();
    _precioController.dispose();
    _nuevoTipoPapelController.dispose();
    _nuevoGramajeController.dispose();
    _nuevoTamanoController.dispose();
    super.dispose();
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    // Validación: Determinar si usamos el valor del menú o el texto nuevo
    final tipoPapelFinal = _esNuevoTipoPapel ? _nuevoTipoPapelController.text.trim() : _selectedTipoPapel;
    final gramajeFinal = _esNuevoGramaje ? _nuevoGramajeController.text.trim() : _selectedGramaje;
    final tamanoFinal = _esNuevoTamano ? _nuevoTamanoController.text.trim() : _selectedTamano;

    if (tipoPapelFinal == null || tipoPapelFinal.isEmpty || 
        gramajeFinal == null || gramajeFinal.isEmpty || 
        tamanoFinal == null || tamanoFinal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos de configuración.'), backgroundColor: Color(0xFFf9a825)),
      );
      return;
    }

    final vm = context.read<InsumoViewModel>();
    
    // Como el if de arriba ya descartó los nulls, Dart sabe que aquí son String puros. Ya no necesitan "!"
    final exito = await vm.guardarInsumo(
      id: widget.insumoAEditar?.id,
      nombre: _nombreController.text,
      tipoPapel: tipoPapelFinal, 
      gramaje: gramajeFinal,     
      tamano: tamanoFinal,       
      stockStr: _stockController.text,
      precioStr: _precioController.text,
    );

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insumo guardado con éxito'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.mensajeDeErrorVisible ?? 'Error desconocido'), backgroundColor: const Color(0xFFd32f2f)),
      );
      vm.limpiarError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InsumoViewModel>();
    final esEdicion = widget.insumoAEditar != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Insumo' : 'Nuevo Insumo', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0056b3),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: vm.estaCargandoParametros || !_inicializado
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0056b3)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre o Identificación del Insumo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- SWITCH: TIPO DE PAPEL ---
                    if (_esNuevoTipoPapel)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nuevoTipoPapelController,
                              decoration: const InputDecoration(labelText: 'Nuevo Tipo de Papel', border: OutlineInputBorder(), helperText: 'Ej: Fotográfico'),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Requerido';
                                }
                                return null;
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFFd32f2f)),
                            onPressed: () {
                              setState(() { 
                                _esNuevoTipoPapel = false; 
                                _selectedTipoPapel = null; 
                                _nuevoTipoPapelController.clear(); 
                              });
                            },
                          ),
                        ],
                      )
                    else
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Tipo de Papel', border: OutlineInputBorder()),
                        initialValue: _selectedTipoPapel,
                        items: [
                          ...vm.tiposPapel.where((e) => e != 'Otro').map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo))),
                          const DropdownMenuItem(value: 'Otro', child: Text('Otro (Ingresar nuevo)...', style: TextStyle(color: Color(0xFF0056b3), fontStyle: FontStyle.italic))),
                        ],
                        onChanged: (val) {
                          if (val == 'Otro') {
                            setState(() {
                              _esNuevoTipoPapel = true;
                            });
                          } else {
                            setState(() {
                              _selectedTipoPapel = val;
                            });
                          }
                        },
                      ),
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- SWITCH: GRAMAJE ---
                        Expanded(
                          child: _esNuevoGramaje
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _nuevoGramajeController,
                                        decoration: const InputDecoration(labelText: 'Nuevo Gramaje', border: OutlineInputBorder(), helperText: 'Ej: 200g'),
                                        validator: (val) {
                                          if (val == null || val.trim().isEmpty) {
                                            return 'Requerido';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Color(0xFFd32f2f)),
                                      onPressed: () {
                                        setState(() { 
                                          _esNuevoGramaje = false; 
                                          _selectedGramaje = null; 
                                          _nuevoGramajeController.clear(); 
                                        });
                                      },
                                    ),
                                  ],
                                )
                              : DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(labelText: 'Gramaje', border: OutlineInputBorder()),
                                  initialValue: _selectedGramaje,
                                  items: [
                                    ...vm.gramajes.where((e) => e != 'Otro').map((g) => DropdownMenuItem(value: g, child: Text(g))),
                                    const DropdownMenuItem(value: 'Otro', child: Text('Otro...', style: TextStyle(color: Color(0xFF0056b3), fontStyle: FontStyle.italic))),
                                  ],
                                  onChanged: (val) {
                                    if (val == 'Otro') {
                                      setState(() {
                                        _esNuevoGramaje = true;
                                      });
                                    } else {
                                      setState(() {
                                        _selectedGramaje = val;
                                      });
                                    }
                                  },
                                ),
                        ),
                        const SizedBox(width: 8),

                        // --- SWITCH: TAMAÑO ---
                        Expanded(
                          child: _esNuevoTamano
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _nuevoTamanoController,
                                        decoration: const InputDecoration(labelText: 'Nuevo Tamaño', border: OutlineInputBorder(), helperText: 'Ej: 10x15'),
                                        validator: (val) {
                                          if (val == null || val.trim().isEmpty) {
                                            return 'Requerido';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Color(0xFFd32f2f)),
                                      onPressed: () {
                                        setState(() { 
                                          _esNuevoTamano = false; 
                                          _selectedTamano = null; 
                                          _nuevoTamanoController.clear(); 
                                        });
                                      },
                                    ),
                                  ],
                                )
                              : DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(labelText: 'Tamaño', border: OutlineInputBorder()),
                                  initialValue: _selectedTamano,
                                  items: [
                                    ...vm.tamanos.where((e) => e != 'Otro').map((t) => DropdownMenuItem(value: t, child: Text(t))),
                                    const DropdownMenuItem(value: 'Otro', child: Text('Otro...', style: TextStyle(color: Color(0xFF0056b3), fontStyle: FontStyle.italic))),
                                  ],
                                  onChanged: (val) {
                                    if (val == 'Otro') {
                                      setState(() {
                                        _esNuevoTamano = true;
                                      });
                                    } else {
                                      setState(() {
                                        _selectedTamano = val;
                                      });
                                    }
                                  },
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Validación numérica
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Stock (Unidades)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.inventory_2)),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Requerido';
                              final num = int.tryParse(value);
                              if (num == null) return 'Solo números';
                              if (num < 0) return 'No negativo';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _precioController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Precio Unitario (\$)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Requerido';
                              final num = double.tryParse(value);
                              if (num == null) return 'Solo números';
                              if (num < 0) return 'No negativo';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: vm.estaCargando ? null : _guardar,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056b3)),
                        child: vm.estaCargando
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('GUARDAR INSUMO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}