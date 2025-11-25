import 'package:flutter/material.dart';
// Importiamo solo la Home Screen
import 'package:frontend/ui/screens/home/home_screen.dart';

void main() {
  // Avviamo direttamente l'app senza avvolgerla nei Provider
  runApp(const SAfeGuard());
}

class SAfeGuard extends StatelessWidget {
  const SAfeGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeGuard',
      debugShowCheckedModeBanner: false,

      // TEMA GLOBALE
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF041528), // Blu Scuro
          primary: const Color(0xFF041528),
          secondary: const Color(0xFFEF923D), // Arancione
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF041528),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold
          ),
        ),
      ),

      // AVVIO DIRETTO DELLA HOME
      home: const HomeScreen(),
    );
  }
}