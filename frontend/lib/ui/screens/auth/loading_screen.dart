import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/screens/auth/registration_screen.dart';
import 'package:frontend/ui/screens/home/home_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late Future<void> _autoLoginFuture;

  @override
  void initState() {
    super.initState();
    // Avviamo il tentativo di auto-login appena il widget viene inizializzato.
    _autoLoginFuture = Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    // Variabili per la responsività
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final double referenceSize = screenHeight < screenWidth ? screenHeight : screenWidth;
    final double titleFontSize = referenceSize * 0.08;
    final double logoSize = referenceSize * 0.45;
    final double mainTextFontSize = referenceSize * 0.055;
    final double secondaryTextFontSize = referenceSize * 0.035;

    final Color darkBackground = const Color(0xFF12345A);
    final Color progressCyan = const Color(0xFF00B0FF);

    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.04),

              Text(
                'SAfeGuard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              Image.asset(
                'assets/logo.png',
                width: logoSize,
                errorBuilder: (c, e, s) =>
                    Icon(Icons.security, size: logoSize, color: Colors.orange),
              ),

              const Spacer(),

              Text(
                'Preparazione del\nsistema in corso...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: mainTextFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: screenHeight * 0.02),
              Text(
                'Accedo alla tua posizione...\nResta al sicuro.\nConnessione ai servizi di emergenza...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: secondaryTextFontSize,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              Text(
                'Consiglio: non andare nel panico.',
                style: TextStyle(color: Colors.white70, fontSize: secondaryTextFontSize),
              ),
              SizedBox(height: screenHeight * 0.015),

              //Animazione caricamento della barra
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 3),
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.white24,
                    color: progressCyan,
                    minHeight: referenceSize * 0.015,
                    borderRadius: BorderRadius.circular(10),
                  );
                },
                onEnd: () async {
                  await _autoLoginFuture;

                  if (!context.mounted) return;

                  final authProvider = Provider.of<AuthProvider>(context, listen: false);

                  if (authProvider.isLogged) {
                    // Se loggato -> home screen
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  } else {
                    // Se non loggato -> registration screen (o Login)
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const RegistrationScreen(),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}