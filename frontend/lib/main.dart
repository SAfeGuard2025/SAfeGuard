import 'package:flutter/material.dart';
import 'package:frontend/ui/screens/auth/loading_screen.dart';
import 'package:frontend/ui/screens/auth/registration_screen.dart';
import 'package:provider/provider.dart';

// IMPORT DEI PROVIDER
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/medical_provider.dart';
import 'package:frontend/providers/emergency_provider.dart';

// IMPORT DELLA SCHERMATA DI LOGIN
import 'package:frontend/ui/screens/auth/login_screen.dart';

void main() {
  runApp(
    // È FONDAMENTALE avvolgere l'app nel MultiProvider,
    // altrimenti la LoginScreen non troverà l'AuthProvider e l'app andrà in crash.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicalProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyProvider()),
      ],
      child: const SAfeGuard(),
    ),
  );
}

class SAfeGuard extends StatelessWidget {
  const SAfeGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeGuard',
      debugShowCheckedModeBanner: false,

      // --- TEMA GLOBALE ---
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF041528),
          primary: const Color(0xFF041528),
          secondary: const Color(0xFFEF923D),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF041528),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // --- PUNTO DI INGRESSO ---
      // Impostiamo la LoginScreen come prima pagina
      home: const LoadingScreen(),
    );
  }
}
