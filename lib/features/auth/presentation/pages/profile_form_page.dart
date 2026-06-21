import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rut_validator/rut_validator.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/validators/campo_validators.dart';
import '../../../../core/models/perfil_trabajador.dart';
import '../../../../core/services/audit_service.dart';
import '../../../../core/services/logging_service.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/personal_viewmodel.dart'; // Agregamos el import de la lista
import 'package:intl/intl.dart';

class ProfileFormPage extends StatefulWidget {
  /// [RF17] Modo de visualización: true = ver mi perfil (lectura), false = crear nuevo perfil (edición)
  final bool modoVisualizacion;
  
  /// [RF17] Perfil a mostrar en modo visualización (requerido si modoVisualizacion=true)
  final PerfilTrabajador? perfilAMostrar;

  const ProfileFormPage({
    super.key,
    this.modoVisualizacion = false,
    this.perfilAMostrar,
  });

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final AuditService _auditService = AuditService();
  final LoggingService _loggingService = LoggingService();
  
  late final TextEditingController _nombreController;
  late final TextEditingController _rutController;
  late final TextEditingController _correoController;
  late final TextEditingController _sueldoController;
  late final TextEditingController _passwordController;

  String? _cargoSeleccionado;
  String? _rolSeleccionado;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Variable para saber si estamos editando un trabajador existente
  bool get esModoEdicion => !widget.modoVisualizacion && widget.perfilAMostrar != null;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _rutController = TextEditingController();
    _correoController = TextEditingController();
    _sueldoController = TextEditingController();
    _passwordController = TextEditingController();

    // Si nos pasan un perfil (ya sea para Ver o para Editar), llenamos los campos
    if (widget.perfilAMostrar != null) {
      _cargarDatosPerfil(widget.perfilAMostrar!);
    }
  }

  void _cargarDatosPerfil(PerfilTrabajador perfil) {
    _nombreController.text = perfil.nombreCompleto;
    _rutController.text = perfil.rut;
    _correoController.text = perfil.correoElectronico;
    _sueldoController.text = perfil.sueldoBase.toStringAsFixed(0);
    _cargoSeleccionado = perfil.cargo;
    _rolSeleccionado = perfil.rol;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rutController.dispose();
    _correoController.dispose();
    _sueldoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  List<String> _obtenerCargosParaRol() {
    if (_rolSeleccionado == null) return [];
    return AppConfig.getCargosParaRol(_rolSeleccionado!);
  }

  void _alCambiarCargo(String? nuevoCargo) {
    setState(() {
      _cargoSeleccionado = nuevoCargo;
    });
  }

  void _alCambiarRol(String? nuevoRol) {
    setState(() {
      _rolSeleccionado = nuevoRol;
      if (_cargoSeleccionado != null && nuevoRol != null) {
        final cargosValidos = AppConfig.getCargosParaRol(nuevoRol);
        if (!cargosValidos.contains(_cargoSeleccionado)) {
          _cargoSeleccionado = null;
        }
      }
    });
  }

  String? _validarCargoConRol(String? value) {
    return CampoValidators.validarCargoPorRol(value, _rolSeleccionado);
  }

  bool _debenEstarCongelados() {
    return widget.modoVisualizacion;
  }

  void _guardarPerfil() async {
    if (_formKey.currentState!.validate()) {
      
      // -- FLUJO 1: EDITAR UN TRABAJADOR EXISTENTE --
      if (esModoEdicion) {
        final personalVM = Provider.of<PersonalViewModel>(context, listen: false);
        final idTrabajador = widget.perfilAMostrar!.id!; // El ID de Firebase

        final nuevosDatos = {
          'nombreCompleto': _nombreController.text.trim(),
          'correoElectronico': _correoController.text.trim(),
          'cargo': _cargoSeleccionado!,
          'rol': _rolSeleccionado!,
          'sueldoBase': double.parse(_sueldoController.text),
        };

        final exito = await personalVM.actualizarTrabajador(idTrabajador, nuevosDatos);

        if (!mounted) return;

        if (exito) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trabajador actualizado correctamente'), backgroundColor: Colors.green));
          Navigator.pop(context); // Regresa a la lista
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar el trabajador'), backgroundColor: Colors.red));
        }
      } 
      // -- FLUJO 2: CREAR UN TRABAJADOR NUEVO --
      else {
        final vm = Provider.of<LoginViewModel>(context, listen: false);

        final exito = await vm.registrarTrabajadorCompleto(
          nombre: _nombreController.text,
          rut: _rutController.text,
          correo: _correoController.text,
          cargo: _cargoSeleccionado!,
          rol: _rolSeleccionado!,
          sueldoTexto: _sueldoController.text,
          password: _passwordController.text,
        );

        if (!mounted) return;

        if (exito) {
          final rutFormateado = RutValidator.format(_rutController.text);
          final perfil = PerfilTrabajador(
            rut: _rutController.text.trim(),
            nombreCompleto: _nombreController.text.trim(),
            correoElectronico: _correoController.text.trim(),
            cargo: _cargoSeleccionado!,
            rol: _rolSeleccionado!,
            sueldoBase: double.parse(_sueldoController.text),
          );

          _auditService.registrarIntentoCreacionPerfil(perfil);
          _auditService.registrarExitoCreacionPerfil(perfil);
          _loggingService.registrarCreacionExitosa(perfil);

          _mostrarDialogoExito(perfil, rutFormateado);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vm.mensajeDeErrorVisible ?? 'Error de conexión'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _mostrarDialogoExito(PerfilTrabajador perfil, String rutFormateado) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 24),
            SizedBox(width: 12),
            Expanded(child: Text('Perfil Creado', style: TextStyle(fontSize: 18))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField('Nombre', perfil.nombreCompleto),
              _buildDialogField('RUT', rutFormateado),
              _buildDialogField('Correo', perfil.correoElectronico),
              _buildDialogField('Cargo', perfil.cargo),
              _buildDialogField('Rol', perfil.rol),
              _buildDialogField('Sueldo', '\$${perfil.sueldoBase.toStringAsFixed(0)}'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: AppColors.success, size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text('Perfil registrado exitosamente', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w500, fontSize: 12))),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _limpiarFormulario();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12, color: AppColors.onSurface)),
          const Divider(height: 12),
        ],
      ),
    );
  }

  void _limpiarFormulario() {
    _formKey.currentState!.reset();
    _nombreController.clear();
    _rutController.clear();
    _correoController.clear();
    _sueldoController.clear();
    _passwordController.clear();
    setState(() {
      _cargoSeleccionado = null;
      _rolSeleccionado = null;
    });
    _auditService.registrarLimpiezaFormulario();
  }

  @override
  Widget build(BuildContext context) {
    final congelado = _debenEstarCongelados();
    
    // Cambiar el título de arriba según lo que estemos haciendo
    String tituloAppBar = 'Crear Perfil de Trabajador';
    if (widget.modoVisualizacion) tituloAppBar = 'Mi Perfil';
    if (esModoEdicion) tituloAppBar = 'Editar Trabajador';
    
    return Scaffold(
      appBar: AppBar(title: Text(tituloAppBar)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.modoVisualizacion && !esModoEdicion) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.info),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info, color: AppColors.info, size: 20),
                        SizedBox(width: 8),
                        Expanded(child: Text('Solo administradores pueden crear perfiles', style: TextStyle(color: AppColors.info, fontSize: 12))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                TextFormField(
                  controller: _nombreController,
                  readOnly: congelado,
                  decoration: const InputDecoration(labelText: 'Nombre completo', hintText: 'Ej: Juan Pérez', prefixIcon: Icon(Icons.person)),
                  validator: CampoValidators.validarNombre,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _rutController,
                  // El RUT no se debería poder editar porque es la llave del correo, lo bloqueamos en modo edición
                  readOnly: congelado || esModoEdicion,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\.kK]'))],
                  decoration: const InputDecoration(labelText: 'RUT', hintText: 'Ej: 12.345.678-9', prefixIcon: Icon(Icons.badge)),
                  validator: CampoValidators.validarRut,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final formatted = CampoValidators.formatearRut(value);
                      if (formatted != value) {
                        _rutController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.fromPosition(TextPosition(offset: formatted.length)),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _correoController,
                  readOnly: congelado,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo electrónico', hintText: 'Ej: juan@imprenta.cl', prefixIcon: Icon(Icons.email)),
                  validator: CampoValidators.validarCorreo,
                ),
                const SizedBox(height: 16),

                // Ocultamos la contraseña en lectura Y en edición
                if (!widget.modoVisualizacion && !esModoEdicion)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña inicial',
                          hintText: 'Mín 8 caracteres (mayúscula, minúscula, número)',
                          prefixIcon: Icon(Icons.lock),
                          helperText: 'Ej: Pass1234',
                          isDense: true,
                          errorMaxLines: 3,
                        ),
                        obscureText: true,
                        validator: CampoValidators.validarContrasena,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                DropdownButtonFormField<String>(
                  initialValue: _rolSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Rol de Seguridad', 
                    prefixIcon: Icon(Icons.security), 
                    helperText: 'Selecciona el rol del trabajador',
                  ),
                  items: AppConfig.todosRoles
                    .map((rol) => DropdownMenuItem(value: rol, child: Text(rol)))
                    .toList(),
                  onChanged: congelado ? null : _alCambiarRol,
                  validator: (value) => CampoValidators.validarRol(value, _cargoSeleccionado),
                  hint: const Text('Selecciona un rol'),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _cargoSeleccionado,
                  decoration: InputDecoration(
                    labelText: 'Cargo', 
                    prefixIcon: const Icon(Icons.work),
                    helperText: _rolSeleccionado != null 
                      ? 'Cargos disponibles para el rol seleccionado'
                      : 'Selecciona un rol primero',
                  ),
                  items: _rolSeleccionado == null 
                    ? [] 
                    : _obtenerCargosParaRol()
                        .map((cargo) => DropdownMenuItem(value: cargo, child: Text(cargo)))
                        .toList(),
                  onChanged: (congelado || _rolSeleccionado == null) ? null : _alCambiarCargo,
                  validator: _validarCargoConRol,
                  disabledHint: const Text('Selecciona un rol primero'),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _sueldoController,
                  readOnly: congelado,
                  decoration: const InputDecoration(labelText: 'Sueldo base (CLP)', hintText: 'Ej: 500000', prefixIcon: Icon(Icons.attach_money), helperText: 'Mínimo legal: \$460.000'),
                  keyboardType: TextInputType.number,
                  validator: CampoValidators.validarSueldo,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final numeroLimpio = int.tryParse(value.replaceAll('.', '')) ?? 0;
                      final formateado = NumberFormat.currency(locale: 'es_CL', symbol: '', decimalDigits: 0).format(numeroLimpio).trim();
                      if (formateado != value) {
                        _sueldoController.value = TextEditingValue(
                          text: formateado,
                          selection: TextSelection.fromPosition(TextPosition(offset: formateado.length)),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 32),

                if (!widget.modoVisualizacion)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _guardarPerfil, 
                          icon: const Icon(Icons.send), 
                          // Cambiamos el texto del botón si estamos editando
                          label: Text(esModoEdicion ? 'Guardar Cambios' : 'Guardar Perfil'),
                        )
                      ),
                      // Ocultamos el botón de limpiar en modo edición para evitar accidentes
                      if (!esModoEdicion) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _limpiarFormulario, 
                            icon: const Icon(Icons.clear), 
                            label: const Text('Limpiar'),
                          )
                        ),
                      ]
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}