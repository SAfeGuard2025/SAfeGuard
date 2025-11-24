import 'package:flutter/material.dart';
import 'package:frontend/screens/emailLogin.dart';
import 'package:frontend/screens/homePage.dart';
import 'package:frontend/screens/phoneLogin.dart';
import 'package:frontend/screens/registrationScreen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color darkBlue = const Color(0xFF041528);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        centerTitle: true,

        // --- MODIFICA PER LA PARTE SINISTRA (Back + Registrati) ---
        leadingWidth: 120, // Allarghiamo lo spazio a sinistra per far entrare il testo
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(), // Rende cliccabile tutta l'area
          child: Row(
            children: [
              const SizedBox(width: 10),
              const Text(
                "Accedi",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        title: Image.asset(
          'assets/logo.png',
          height: 40,
          errorBuilder: (c,e,s) => const Icon(Icons.shield, color: Colors.white),
        ),

        // Tasto Skip (Destra)
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HomePage(), // Assicurati che HomePage sia importata
                ),
              );
            },
            child: const Text("Skip", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),

      // Il corpo della pagina
      body: Stack(
        children: [
          // --- LAYER 1: L'IMMAGINE DI SFONDO ---
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

          // --- LAYER 2: IL CONTENUTO ---
          SafeArea(
            child: Column(
              children: [
                // PARTE ALTA (Logo e Testi)
                const SizedBox(height: 20),

                Padding(
                  // 3. MODIFICA: Ho ridotto il padding verticale (era 20 e 40)
                  // Mettendo 5 sopra e 10 sotto, tutto si sposta PIÙ IN ALTO.
                  padding: const EdgeInsets.fromLTRB(25, 5, 25, 10),
                  child: Row(
                    children: [
                      // Logo
                      Image.asset(
                        'assets/stylizedMascot.png',
                        width: 100,
                        color: darkBlue,
                        errorBuilder: (c,e,s) => Icon(Icons.shield, size: 80, color: darkBlue),
                      ),
                      const SizedBox(width: 20),
                      // Testi
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // 1. Questo allinea i blocchi di testo al centro orizzontalmente
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Bentornato in\nSAfeGuard",
                              // 2. Questo centra le scritte quando vanno su due righe
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 35,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Accedi per connetterti alla rete di emergenza",
                              // 3. Anche questo centrato
                              textAlign: TextAlign.center,
                              style: TextStyle(color: darkBlue, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // PARTE BASSA (Bottoni)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildSocialButton(text: "Continua con Apple", icon: Icons.apple, backgroundColor: Colors.black, textColor: Colors.white),
                        const SizedBox(height: 15),
                        _buildSocialButton(text: "Continua con Google", imagePath: 'assets/googleIcon.png', backgroundColor: Colors.white, textColor: Colors.black, iconColor: Colors.red),
                        const SizedBox(height: 15),
                        _buildSocialButton(
                          text: "Continua con Email", icon: Icons.alternate_email, backgroundColor: Colors.white, textColor: Colors.black, iconColor: darkBlue,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const EmailLogin()),
                            );
                          },
                        ),

                        const SizedBox(height: 15),

                        _buildSocialButton(
                          text: "Continua con Telefono", icon: Icons.phone, backgroundColor: Colors.white, textColor: Colors.black, iconColor: darkBlue,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const PhoneLogin()),
                            );
                          },
                        ),
                        const SizedBox(height: 80),

                        // Footer Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Non hai un account? ", style: TextStyle(color: Colors.white)),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                                );
                              },
                              child: const Text("Registrati", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 50),
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

  // --- Helper Bottoni (Rimasto uguale) ---
  Widget _buildSocialButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,       // Opzionale
    String? imagePath,    // Opzionale (per Google)
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
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
            if (imagePath != null)
              Image.asset(imagePath, height: 24)
            else if (icon != null)
              Icon(icon, color: iconColor ?? textColor, size: 24),
            Expanded(
              child: Center(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}