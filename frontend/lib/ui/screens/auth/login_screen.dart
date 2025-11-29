import 'package:flutter/material.dart';
import 'package:frontend/ui/screens/auth/email_login_screen.dart';
import 'package:frontend/ui/screens/auth/phone_login_screen.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/screens/auth/registration_screen.dart';
import 'package:frontend/ui/screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/style/color_palette.dart';
import 'package:frontend/ui/widgets/google_logo.dart';

// Schermata Principale di Accesso
// Offre diverse opzioni di login (Social, Email, Telefono).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Accesso all'AuthProvider (per le chiamate di login)
    final authProvider = Provider.of<AuthProvider>(context);
    final Color darkBlue = ColorPalette.backgroundDeepBlue;

    // Variabili per la responsività
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final double referenceSize = screenHeight < screenWidth ? screenHeight : screenWidth;
    final double verticalSpacing = screenHeight * 0.015;
    final double mascotSize = referenceSize * 0.22;
    final double titleFontSize = referenceSize * 0.065;
    final double subtitleFontSize = referenceSize * 0.035;
    final double buttonTextFontSize = referenceSize * 0.04;

    // Dimensione standard per le icone nei pulsanti (basata sul testo)
    final double iconSize = buttonTextFontSize * 1.5;

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
          height: screenHeight * 0.05,
          errorBuilder: (c, e, s) =>
          const Icon(Icons.shield, color: Colors.white),
        ),

        // Pulsante "Skip" (Salta Login)
        actions: [
          TextButton(
            onPressed: () {
              // Naviga alla Home senza autenticazione
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

      body: Stack(
        children: [
          // Sfondo
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgroundBubbles2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Contenuto principale
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.04),
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 5, 25, 10),
                  child: Row(
                    children: [
                      // Area testo e titoli
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                    fontWeight: FontWeight.bold
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
                        child: Image.asset(
                          'assets/stylizedMascot.png',
                          width: mascotSize,
                          color: darkBlue,
                          errorBuilder: (c, e, s) =>
                              Icon(Icons.shield, size: mascotSize, color: darkBlue),
                        ),
                      ),
                    ],
                  ),
                ),

                //Zona pulsanti
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        // Bottone Login Apple
                        _buildSocialButton(
                          text: "Continua con Apple",
                          icon: Icon(Icons.apple, color: Colors.white, size: iconSize),
                          iconSize: iconSize,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: buttonTextFontSize,
                          onTap: () async {
                            final success = await authProvider.signInWithApple();
                            if (success && context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const HomeScreen()),
                              );
                            }
                          },
                        ),
                        SizedBox(height: verticalSpacing),

                        // Bottone Login Google (MODIFICATO con ChromeLogoIcon)
                        _buildSocialButton(
                          text: "Continua con Google",
                          icon: ChromeLogoIcon(size: iconSize),
                          iconSize: iconSize,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          fontSize: buttonTextFontSize,
                          onTap: () async {
                            final success = await authProvider.signInWithGoogle();
                            if (success && context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const HomeScreen()),
                              );
                            }
                          },
                        ),
                        SizedBox(height: verticalSpacing),

                        // Bottone Login Email
                        _buildSocialButton(
                          text: "Continua con Email",
                          icon: Icon(Icons.alternate_email, color: darkBlue, size: iconSize),
                          iconSize: iconSize,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          fontSize: buttonTextFontSize,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmailLoginScreen(),
                            ),
                          ),
                        ),
                        SizedBox(height: verticalSpacing),

                        // Bottone Login Telefono
                        _buildSocialButton(
                          text: "Continua con Telefono",
                          icon: Icon(Icons.phone, color: darkBlue, size: iconSize),
                          iconSize: iconSize,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          fontSize: buttonTextFontSize,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PhoneLoginScreen(),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.05),

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
                                  builder: (context) =>
                                  const RegistrationScreen(),
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
                        SizedBox(height: verticalSpacing * 2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper per costruire i bottoni Social/Classici (AGGIORNATO)
  Widget _buildSocialButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required Widget icon, // Ora accetta un Widget generico
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