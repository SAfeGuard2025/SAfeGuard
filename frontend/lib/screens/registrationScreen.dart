import 'package:flutter/material.dart';
import 'package:frontend/screens/emailRegister.dart';
import 'package:frontend/screens/homePage.dart';
import 'package:frontend/screens/loginScreen.dart';
import 'package:frontend/screens/phoneRegister.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

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
                "Registrati",
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
                  builder: (context) => const HomePage(),
                ),
              );
            },
            child: const Text("Skip", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),

      body: Stack(
        children: [
          // LAYER 1: SFONDO
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgroundBubbles1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // LAYER 2: CONTENUTO
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // PARTE ALTA: LOGO E TESTI
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 5, 25, 10),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/stylizedMascot.png',
                        width: 100,
                        color: darkBlue,
                        errorBuilder: (c,e,s) => Icon(Icons.shield, size: 80, color: darkBlue),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Benvenuto in\nSAfeGuard",
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
                              "Registrati per connetterti alla rete di emergenza",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: darkBlue, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // PARTE BASSA: BOTTONI
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
                              MaterialPageRoute(builder: (context) => const EmailRegister()),
                            );
                          },
                        ),

                        const SizedBox(height: 15),

                        _buildSocialButton(
                            text: "Continua con Telefono", icon: Icons.phone, backgroundColor: Colors.white, textColor: Colors.black, iconColor: darkBlue,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const PhoneRegister()),
                              );
                            },
                        ),

                        const SizedBox(height: 80),

                        // FOOTER LOGIN
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Hai già un account? ", style: TextStyle(color: Colors.white)),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );
                              },
                              child: const Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  // --- HELPER BOTTONI (CORRETTO) ---
  Widget _buildSocialButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    String? imagePath,
    Color? iconColor,
    VoidCallback? onTap, // Parametro ricevuto
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