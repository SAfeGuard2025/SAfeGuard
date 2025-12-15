import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/screens/auth/registration_screen.dart';
import 'package:frontend/ui/screens/home/home_screen.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Schermata di Caricamento
// Gestisce l'inizializzazione dell'app e il tentativo di auto-login.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  // Future che conterrà il risultato del tentativo di auto-login
  late Future<void> _autoLoginFuture;

  @override
  void initState() {
    super.initState();
    // Avvia il tentativo di auto-login appena il widget viene inizializzato.
    _autoLoginFuture = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    // Variabili per la responsività
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final double referenceSize = screenHeight < screenWidth
        ? screenHeight
        : screenWidth;
    final double titleFontSize = referenceSize * 0.08;
    final double mainTextFontSize = referenceSize * 0.055;
    final double secondaryTextFontSize = referenceSize * 0.035;

    final Color darkBackground = ColorPalette.backgroundMidBlue;
    final Color progressCyan = ColorPalette.progressCyan;

    //Animazione caricamento
    final Widget loaderWidget = TweenAnimationBuilder<double>(
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

      // Azione eseguita al termine dell'animazione
      onEnd: () async {
        await _autoLoginFuture;

        if (!context.mounted) return; // Controllo di sicurezza

        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        if (authProvider.isLogged) {
          // Se loggato -> home screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // Se non loggato -> registration screen (o Login)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RegistrationScreen()),
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isLandscape = constraints.maxWidth > constraints.maxHeight;

            // Gestione del layout per dispositivi posti in orizzontale
            if (isLandscape) {
              return Padding(
                padding: const EdgeInsets.all(30.0),
                child: Row(
                  children: [
                    // Logo dell'app
                    Expanded(
                      flex: 1,
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.security,
                          size: 100,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'SAfeGuard',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Messaggio principale di caricamento
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Preparazione del\nsistema in corso...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: mainTextFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          // Messaggi secondari e suggerimenti
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Accedo alla tua posizione...\nResta al sicuro.\nConnessione ai servizi di emergenza...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: secondaryTextFontSize,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          loaderWidget,
                          SizedBox(height: constraints.maxHeight * 0.02),
                          // Suggerimento extra
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Consiglio: non andare nel panico.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: secondaryTextFontSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              // Gestione del layout per dispositivi posti in verticale
            } else {
              return Padding(
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

                    // Logo dell'app
                    Expanded(
                      flex: 2,
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => Icon(
                          Icons.security,
                          size: referenceSize * 0.45,
                          color: Colors.orange,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Messaggio principale di caricamento
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Preparazione del\nsistema in corso...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: mainTextFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Messaggi secondari e suggerimenti
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Accedo alla tua posizione...\nResta al sicuro.\nConnessione ai servizi di emergenza...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: secondaryTextFontSize,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Suggerimento extra
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Consiglio: non andare nel panico.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: secondaryTextFontSize,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    loaderWidget,
                    SizedBox(height: screenHeight * 0.04),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
