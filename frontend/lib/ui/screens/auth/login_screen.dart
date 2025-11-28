import 'package:flutter/material.dart';
import 'package:frontend/ui/screens/auth/email_login_screen.dart';
import 'package:frontend/ui/screens/auth/phone_login_screen.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/screens/auth/registration_screen.dart';
import 'package:frontend/ui/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context);

    final Color darkBlue = const Color(0xFF041528);

    //HEADER DELL'APP
    return Scaffold(
      //BARRA NAVIGAZIONALE SOPRA CON: REGISTRAZIONE - ICONA - SKIP
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 120,
        leading: const Padding(
          padding: EdgeInsets.only(left: 10),
          //ACCENTRA IL TESTO + ZONA TESTO REGISTRAZIONE
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
        title: Image.asset(
          'assets/logo.png',
          height: 40,
          errorBuilder: (c, e, s) =>
              const Icon(Icons.shield, color: Colors.white),
        ),
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

      //BODY
      body: Stack(
        children: [
          // SFONDO
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
          // CONTENUTO
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 5, 25, 10),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/stylizedMascot.png',
                        width: 100,
                        color: darkBlue,
                        errorBuilder: (c, e, s) =>
                            Icon(Icons.shield, size: 80, color: darkBlue),
                      ),
                      const SizedBox(width: 20),
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
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Accedi per connetterti alla rete di emergenza",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: darkBlue, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                //ZONA PULSANTI
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // CONTINUA CON APPLE
                        _buildSocialButton(
                          text: "Continua con Apple",
                          icon: Icons.apple,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          onTap: () async {
                            final success = await authProvider.signInWithApple();
                            if (success && context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const HomeScreen()),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 15),

// CONTINUA CON GOOGLE
                        _buildSocialButton(
                          text: "Continua con Google",
                          imagePath: 'assets/googleIcon.png',
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          iconColor: Colors.red,
                          onTap: () async {
                            final success = await authProvider.signInWithGoogle();
                            if (success && context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const HomeScreen()),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 15),

                        //CONTINUA CON EMAIL FUNZIONA E CONTINUA SU email_register_screen
                        _buildSocialButton(
                          text: "Continua con Email",
                          icon: Icons.alternate_email,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          iconColor: darkBlue,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmailLoginScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        //CONTINUA CON TELEFONO FUNZIONA E CONTINUA SU phone_register_screen
                        _buildSocialButton(
                          text: "Continua con Telefono",
                          icon: Icons.phone,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          iconColor: darkBlue,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PhoneLoginScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),

                        //PARTE BASSA, HAI GIA' UN ACCOUNT - REINDIRIZZATO AL registration_screen
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

                              //SCRITTA CLICCABILE
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
                        const SizedBox(height: 30),
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

  //DA METTERE IN UN ALTRO FILE
  Widget _buildSocialButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    String? imagePath,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
