import 'package:flutter/material.dart';
import 'package:frontend/ui/screens/auth/email_login_screen.dart';
import 'package:frontend/ui/screens/auth/phone_login_screen.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/screens/auth/registration_screen.dart';
import 'package:frontend/ui/screens/home/home_screen.dart';
import 'package:frontend/ui/widgets/blue_seahorse.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/style/color_palette.dart';
import 'package:frontend/ui/widgets/google_logo.dart';
import '../../widgets/bubble_background.dart';

// Schermata Principale di Accesso
// Offre diverse opzioni di login (Social, Email, Telefono).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Accesso all'AuthProvider (per le chiamate di login)
    final authProvider = Provider.of<AuthProvider>(context);
    final Color darkBlue = ColorPalette.backgroundDeepBlue;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 120,
        leading: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Accesso",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),

        // Logo al centro
        title: Image.asset(
          'assets/logo.png',
          height: 40,
          errorBuilder: (c, e, s) =>
              const Icon(Icons.shield, color: Colors.white),
        ),

        // Pulsante "Skip" (Salta Login)
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: const Text(
              "Skip",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      // Layout builder per gestire l'orientamento del dispositivo
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final double height = constraints.maxHeight;
          final bool isLandscape = width > height;

          // Variabili responsive
          final double referenceSize = isLandscape ? height : width;
          final double verticalSpacing = height * 0.015;
          final double mascotSize = referenceSize * 0.22;
          final double titleFontSize = referenceSize * 0.065;
          final double subtitleFontSize = referenceSize * 0.035;
          final double buttonTextFontSize = referenceSize * 0.04;
          final double iconSize = buttonTextFontSize * 1.5;

          return Stack(
            children: [
              // Sfondo
              Positioned.fill(
                child: BubbleBackground(
                  type: isLandscape ? BubbleType.type4 : BubbleType.type2,
                ),
              ),

              // Gestione del layout per dispositivi posti in orizzontale
              if (isLandscape) ...[
                Row(
                  children: [
                    // Sinistra: Mascotte e Testi
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BlueSeahorse(size: height * 0.3),
                          SizedBox(height: height * 0.05),

                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Bentornato in\nSAfeGuard",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: height * 0.08,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                          ),

                          SizedBox(height: height * 0.02),

                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Accedi per connetterti alla rete di emergenza",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: darkBlue,
                                  fontSize: height * 0.035,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Destra: Pulsanti
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildButtonsList(
                              context,
                              authProvider,
                              darkBlue,
                              buttonTextFontSize,
                              iconSize,
                              isLandscape: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Gestione del layout per dispositivi posti in verticale
              ] else ...[
                Column(
                  children: [
                    SizedBox(height: height * 0.04),

                    // Area Testo e Mascotte
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 5, 25, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Bentornato in\nSAfeGuard",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: verticalSpacing),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Accedi per connetterti alla rete di emergenza",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: darkBlue,
                                      fontSize: subtitleFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 20),

                          // Mascotte specchiata
                          Transform.flip(
                            flipX: true,
                            child: BlueSeahorse(size: mascotSize),
                          ),
                        ],
                      ),
                    ),

                    // Zona Pulsanti
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildButtonsList(
                              context,
                              authProvider,
                              darkBlue,
                              buttonTextFontSize,
                              iconSize,
                              isLandscape: false,
                            ),
                            SizedBox(height: verticalSpacing * 3.5),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // Metodo Helper per raggruppare i pulsanti
  Widget _buildButtonsList(
    BuildContext context,
    AuthProvider authProvider,
    Color darkBlue,
    double fontSize,
    double iconSize, {
    required bool isLandscape,
  }) {
    final double spacing = isLandscape ? 10.0 : 15.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Apple
        _buildSocialButton(
          text: "Continua con Apple",
          icon: Icon(Icons.apple, color: Colors.white, size: iconSize),
          iconSize: iconSize,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: fontSize,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Funzionalità non ancora implementata"),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        SizedBox(height: spacing),

        // Google
        _buildSocialButton(
          text: "Continua con Google",
          icon: ChromeLogoIcon(size: iconSize),
          iconSize: iconSize,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: fontSize,
          onTap: () async {
            final success = await authProvider.signInWithGoogle();
            if (success && context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          },
        ),
        SizedBox(height: spacing),

        // Email
        _buildSocialButton(
          text: "Continua con Email",
          icon: Icon(Icons.alternate_email, color: darkBlue, size: iconSize),
          iconSize: iconSize,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: fontSize,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EmailLoginScreen()),
          ),
        ),
        SizedBox(height: spacing),

        // Telefono
        _buildSocialButton(
          text: "Continua con Telefono",
          icon: Icon(Icons.phone, color: darkBlue, size: iconSize),
          iconSize: iconSize,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: fontSize,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PhoneLoginScreen()),
          ),
        ),

        SizedBox(height: isLandscape ? 10 : 30), // Spazio ridotto in landscape
        // Link Registrazione
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Non hai un account? ",
              style: TextStyle(color: Colors.white),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegistrationScreen(),
                ),
              ),
              child: const Text(
                "Registrati",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget Helper per costruire i bottoni Social/Classici
  Widget _buildSocialButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required Widget icon,
    required double iconSize,
    VoidCallback? onTap,
    required double fontSize,
  }) {
    final double buttonHeight = fontSize * 3.5;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onTap ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 10),

            // Renderizza direttamente il widget passato
            icon,

            // Testo del Bottone centrato
            Expanded(
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Bilanciamento visivo a destra (dimensione icona + padding)
            SizedBox(width: iconSize + 10),
          ],
        ),
      ),
    );
  }
}
