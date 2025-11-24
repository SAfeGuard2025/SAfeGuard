import 'package:flutter/material.dart';
import 'package:frontend/screens/loadingScreen.dart';

void main() {
  runApp(const SAfeGuard());
}

class SAfeGuard extends StatelessWidget {
  const SAfeGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Titolo dell'app
      title: 'SafeGuard',
      debugShowCheckedModeBanner: false,

      // Tema base dell'app
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF041528)),
      ),

      // PUNTO DI INGRESSO: Chiama la schermata di caricamento
      home: const LoadingScreen(),
    );
  }
}