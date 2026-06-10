import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "core/injection.dart";
import "core/theme/app_theme.dart";
import "core/theme/theme_provider.dart";
import "features/auth/presentation/pages/login_page.dart";
import "features/auth/presentation/viewmodels/login_viewmodel.dart";
import "features/auth/presentation/viewmodels/personal_viewmodel.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "features/auth/presentation/pages/home_page.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
            apiKey: "AIzaSyDNwuGZGIzeKQl0vYIkbumB5jNA3Pt--a0",
            authDomain: "imprenta-asistencia.firebaseapp.com",
            projectId: "imprenta-asistencia",
            storageBucket: "imprenta-asistencia.firebasestorage.app",
            messagingSenderId: "1044116654048",
            appId: "1:1044116654048:android:8a7d192783f831c7fc8d85",
          )
        : null,
  );
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppDependencies.buildLoginViewModel(),
        ),
        ChangeNotifierProvider(create: (_) => PersonalViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // --- NUEVA LÍNEA PARA INSUMOS ---
        ChangeNotifierProvider(
          create: (_) => AppDependencies.buildInsumoViewModel(),
        ),
        // --- NUEVA LÍNEA PARA BODEGA ---
        ChangeNotifierProvider(
          create: (_) => AppDependencies.buildBodegaViewModel(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Imprenta App",
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.modoActual,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData) {
                  return const LoginPage();
                }

                return FutureBuilder(
                  future: context
                      .read<LoginViewModel>()
                      .restaurarSesionDesdeFirebase(),
                  builder: (context, sessionSnapshot) {
                    if (sessionSnapshot.connectionState !=
                        ConnectionState.done) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return const HomePage();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
