import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";
import "package:rut_validator/rut_validator.dart";
import "../personal_viewmodel.dart";

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key});

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final llaveDelFormulario = GlobalKey<FormState>();

  final TextEditingController controladorNombreCompleto = TextEditingController();
  final TextEditingController controladorRutTrabajador = TextEditingController();
  final TextEditingController controladorCorreoLaboral = TextEditingController();

  String? valorCargoSeleccionado;
  String? valorRolSeleccionado;

  final List<String> listadoDeCargosDisponibles = ["Impresor", "Diseñador", "Bodeguero", "Supervisor"];
  final List<String> listadoDeRolesAdministrativos = ["Administrador", "Jefe", "Operario"];

  @override
  void dispose() {
    controladorNombreCompleto.dispose();
    controladorRutTrabajador.dispose();
    controladorCorreoLaboral.dispose();
    super.dispose();
  }

  void procesarGuardadoDePerfil() {
    if (llaveDelFormulario.currentState!.validate()) {
      context.read<PersonalViewModel>().registrarNuevoTrabajador(
        controladorNombreCompleto.text,
        RutValidator.format(controladorRutTrabajador.text),
        controladorCorreoLaboral.text,
        valorCargoSeleccionado!,
        valorRolSeleccionado!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Perfil creado exitosamente", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, complete todos los campos obligatorios", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final temaActual = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Nuevo Perfil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: llaveDelFormulario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Datos del Trabajador",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: temaActual.textTheme.bodyLarge?.color),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: controladorNombreCompleto,
                style: TextStyle(color: temaActual.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: "Nombre Completo",
                  filled: true,
                  fillColor: temaActual.colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (valorIngresado) => valorIngresado == null || valorIngresado.isEmpty ? "Debe ingresar el nombre" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: controladorRutTrabajador,
                style: TextStyle(color: temaActual.textTheme.bodyLarge?.color),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\.kK]')),
                ],
                decoration: InputDecoration(
                  labelText: "RUT",
                  hintText: "12.345.678-9",
                  filled: true,
                  fillColor: temaActual.colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: RutValidator.formFieldValidator,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final formatted = RutValidator.format(value);
                    if (formatted != value) {
                      controladorRutTrabajador.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.fromPosition(
                          TextPosition(offset: formatted.length),
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: controladorCorreoLaboral,
                style: TextStyle(color: temaActual.textTheme.bodyLarge?.color),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Correo Electrónico",
                  filled: true,
                  fillColor: temaActual.colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (valorIngresado) => valorIngresado == null || valorIngresado.isEmpty ? "Debe ingresar el correo" : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Cargo",
                  filled: true,
                  fillColor: temaActual.colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                dropdownColor: temaActual.colorScheme.surface,
                style: TextStyle(color: temaActual.textTheme.bodyLarge?.color),
                value: valorCargoSeleccionado,
                items: listadoDeCargosDisponibles.map((cargo) => DropdownMenuItem(value: cargo, child: Text(cargo))).toList(),
                onChanged: (nuevoValor) => setState(() => valorCargoSeleccionado = nuevoValor),
                validator: (valorSeleccionado) => valorSeleccionado == null ? "Seleccione un cargo" : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Rol en el Sistema",
                  filled: true,
                  fillColor: temaActual.colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                dropdownColor: temaActual.colorScheme.surface,
                style: TextStyle(color: temaActual.textTheme.bodyLarge?.color),
                value: valorRolSeleccionado,
                items: listadoDeRolesAdministrativos.map((rol) => DropdownMenuItem(value: rol, child: Text(rol))).toList(),
                onChanged: (nuevoValor) => setState(() => valorRolSeleccionado = nuevoValor),
                validator: (valorSeleccionado) => valorSeleccionado == null ? "Seleccione un rol" : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: procesarGuardadoDePerfil,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: temaActual.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Guardar Perfil", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}