import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/crear_perfil/screens/crear_perfil_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Imprenta',
      theme: AppTheme.lightTheme,
      home: const CrearPerfilPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}