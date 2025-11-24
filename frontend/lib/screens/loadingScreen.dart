import 'package:flutter/material.dart';
import 'package:frontend/screens/registrationScreen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    final Color darkBackground = const Color(0xFF12345A);
    final Color progressCyan = const Color(0xFF00B0FF);

    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // TITOLO
              const Text(
                'SAfeGuard',
                style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold),
              ),

              const Spacer(),

              // LOGO
              Image.asset(
                'assets/logo.png',
                width: 200,
                errorBuilder: (c, e, s) => const Icon(Icons.security, size: 150, color: Colors.orange),
              ),

              const Spacer(),

              // TESTO PRINCIPALE
              const Text(
                'Preparazione del\nsistema in corso...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),

              // SCRITTE SECONDARIE
              const SizedBox(height: 20),
              const Text(
                'Accedo alla tua posizione...\nResta al sicuro.\nConnessione ai servizi di emergenza...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // CONSIGLIO
              const Text(
                'Consiglio: non andare nel panico.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 15),

              // ANIMAZIONE BARRA
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 3),
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.white24,
                    color: progressCyan,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  );
                },
                onEnd: () {
                  // Navigazione alla pagina di Registrazione
                  Navigator.of(context).pushReplacement(
                    // CORREZIONE QUI: La classe si chiama RegistrationScreen, non Registration
                    MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}