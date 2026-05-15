import 'package:firebase_core/firebase_core.dart';
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "core/injection.dart";
import "core/theme/app_theme.dart";
import "core/theme/theme_provider.dart";
import "features/auth/presentation/viewmodels/pages/login_page.dart";
import "features/auth/presentation/viewmodels/personal_viewmodel.dart";

void main() async {
  // 1. Le dice a Flutter que espere a que todo esté listo
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. ¡Enciende el motor de Firebase!
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppDependencies.buildLoginViewModel()),
        ChangeNotifierProvider(create: (_) => PersonalViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Imprenta App",
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.modoActual,
            home: const LoginPage(),
          );
        },
      ),
    );
  }
}