import 'package:flutter/material.dart';
import 'package:rut_validator/rut_validator.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/validators/campo_validators.dart';
import '../../../core/models/perfil_trabajador.dart';
import '../../../core/services/audit_service.dart';
import '../../../core/services/logging_service.dart';

/// [RF2] [RF13] Pantalla de creación de perfil de trabajador
/// Permite al Administrador crear nuevos perfiles con validación centralizada
class CrearPerfilPage extends StatefulWidget {
  const CrearPerfilPage({super.key});

  @override
  State<CrearPerfilPage> createState() => _CrearPerfilPageState();
}

class _CrearPerfilPageState extends State<CrearPerfilPage> {
  /// Servicio de auditoría para registrar eventos
  final AuditService _auditService = AuditService();

  /// Servicio de logging para mostrar eventos en consola
  final LoggingService _loggingService = LoggingService();

  /// Controladores para capturar datos del formulario
  late final TextEditingController _nombreController;
  late final TextEditingController _rutController;
  late final TextEditingController _correoController;
  late final TextEditingController _sueldoController;

  /// Variables de estado para dropdowns
  String? _cargoSeleccionado;
  String? _rolSeleccionado;

  /// Clave global para gestionar el estado del formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _rutController = TextEditingController();
    _correoController = TextEditingController();
    _sueldoController = TextEditingController();
  }

  @override
  void dispose() {
    // Liberar recursos de los controladores
    _nombreController.dispose();
    _rutController.dispose();
    _correoController.dispose();
    _sueldoController.dispose();
    super.dispose();
  }

  /// Obtiene los roles válidos para el cargo seleccionado
  List<String> _obtenerRolesParaCargo() {
    if (_cargoSeleccionado == null) return [];
    return AppConfig.getRolesParaCargo(_cargoSeleccionado!);
  }

  /// Cuando cambia el cargo, resetea el rol seleccionado si no es válido
  void _alCambiarCargo(String? nuevoCargo) {
    setState(() {
      _cargoSeleccionado = nuevoCargo;

      // Si el rol actual no es válido para el nuevo cargo, resetea
      if (_rolSeleccionado != null && nuevoCargo != null) {
        final rolesValidos = _obtenerRolesParaCargo();
        if (!rolesValidos.contains(_rolSeleccionado)) {
          _rolSeleccionado = null;
        }
      }
    });
  }

  /// Valida el rol considerando el cargo seleccionado
  String? _validarRolConCargo(String? value) {
    return CampoValidators.validarRol(value, _cargoSeleccionado);
  }

  /// Guarda el perfil después de validar el formulario
  void _guardarPerfil() {
    if (_formKey.currentState!.validate()) {
      // Formatea el RUT para almacenamiento visual
      final rutFormateado = RutValidator.format(_rutController.text);

      // Crea modelo de perfil
      final perfil = PerfilTrabajador(
        nombreCompleto: _nombreController.text.trim(),
        rut: _rutController.text.trim(),
        correoElectronico: _correoController.text.trim(),
        cargo: _cargoSeleccionado!,
        rol: _rolSeleccionado!,
        sueldoBase: double.parse(_sueldoController.text),
      );

      // Registra el intento en auditoría
      _auditService.registrarIntentoCreacionPerfil(perfil);

      // Registra éxito en auditoría
      _auditService.registrarExitoCreacionPerfil(perfil);

      // Registra en logging (muestra en consola)
      _loggingService.registrarCreacionExitosa(perfil);

      // Despliega diálogo informativo con los datos consolidados
      _mostrarDialogoExito(perfil, rutFormateado);
    }
  }

  /// Muestra diálogo con confirmación de creación
  void _mostrarDialogoExito(PerfilTrabajador perfil, String rutFormateado) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text('Perfil Creado', style: TextStyle(fontSize: 18)),
            ),
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
              _buildDialogField(
                'Sueldo',
                '\$${perfil.sueldoBase.toStringAsFixed(0)}',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: AppColors.success, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Perfil registrado en el sistema',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
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

  /// Widget auxiliar para mostrar campos en el diálogo
  Widget _buildDialogField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, color: AppColors.onSurface),
          ),
          const Divider(height: 12),
        ],
      ),
    );
  }

  /// Limpia el formulario y reinicia los campos
  void _limpiarFormulario() {
    _formKey.currentState!.reset();
    _nombreController.clear();
    _rutController.clear();
    _correoController.clear();
    _sueldoController.clear();

    setState(() {
      _cargoSeleccionado = null;
      _rolSeleccionado = null;
    });

    // Registra en auditoría
    _auditService.registrarLimpiezaFormulario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Perfil de Trabajador')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección informativa
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: AppColors.info, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Solo administradores pueden crear perfiles de trabajadores',
                          style: TextStyle(color: AppColors.info, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Campo: Nombre completo
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    hintText: 'Ej: Juan Pérez González',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: CampoValidators.validarNombre,
                ),
                const SizedBox(height: 16),

                // Campo: RUT Chileno [RF13]
                TextFormField(
                  controller: _rutController,
                  decoration: const InputDecoration(
                    labelText: 'RUT',
                    hintText: 'Ej: 12.345.678-9',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: CampoValidators.validarRut,
                ),
                const SizedBox(height: 16),

                // Campo: Correo electrónico [RF13]
                TextFormField(
                  controller: _correoController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'Ej: juan.perez@imprenta.cl',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: CampoValidators.validarCorreo,
                ),
                const SizedBox(height: 16),

                // Dropdown: Cargo [RF2]
                DropdownButtonFormField<String>(
                  initialValue: _cargoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Cargo',
                    prefixIcon: Icon(Icons.work),
                  ),
                  items: AppConfig.todosCargos
                      .map(
                        (cargo) =>
                            DropdownMenuItem(value: cargo, child: Text(cargo)),
                      )
                      .toList(),
                  onChanged: _alCambiarCargo,
                  validator: CampoValidators.validarCargo,
                ),
                const SizedBox(height: 16),

                // Dropdown: Rol de Seguridad [RF13] - Solo muestra roles válidos para el cargo
                DropdownButtonFormField<String>(
                  initialValue: _rolSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Rol de Seguridad',
                    prefixIcon: Icon(Icons.security),
                    helperText: 'Roles disponibles para el cargo seleccionado',
                  ),
                  items: _obtenerRolesParaCargo()
                      .map(
                        (rol) => DropdownMenuItem(value: rol, child: Text(rol)),
                      )
                      .toList(),
                  onChanged: _cargoSeleccionado != null
                      ? (value) {
                          setState(() {
                            _rolSeleccionado = value;
                          });
                        }
                      : null,
                  validator: _validarRolConCargo,
                  disabledHint: const Text('Selecciona un cargo primero'),
                ),
                const SizedBox(height: 16),

                // Campo: Sueldo base [RF2]
                TextFormField(
                  controller: _sueldoController,
                  decoration: const InputDecoration(
                    labelText: 'Sueldo base (CLP)',
                    hintText: 'Ej: 500000',
                    prefixIcon: Icon(Icons.attach_money),
                    helperText: 'Mínimo legal: \$460.000',
                  ),
                  keyboardType: TextInputType.number,
                  validator: CampoValidators.validarSueldo,
                ),
                const SizedBox(height: 32),

                // Fila de botones [RNF4] Accesibilidad: 44x44px mínimo
                Row(
                  children: [
                    // Botón: Guardar perfil
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _guardarPerfil,
                        icon: const Icon(Icons.send),
                        label: const Text('Guardar perfil'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón: Limpiar
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _limpiarFormulario,
                        icon: const Icon(Icons.clear),
                        label: const Text('Limpiar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
