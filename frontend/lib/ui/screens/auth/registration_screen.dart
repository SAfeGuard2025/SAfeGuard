import 'package:flutter/material.dart';
import 'package:frontend/ui/screens/auth/email_register_screen.dart';
import 'package:frontend/ui/screens/auth/login_screen.dart';
import 'package:frontend/ui/screens/auth/phone_register_screen.dart';
import 'package:frontend/ui/screens/home/home_screen.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color darkBlue = const Color(0xFF041528);

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

    //Header
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
              "Registrazione",
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
          height: screenHeight * 0.05,
          errorBuilder: (c, e, s) =>
          const Icon(Icons.shield, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            ),
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
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: verticalSpacing * 2),

                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 5, 25, 10),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/stylizedMascot.png',
                        width: mascotSize,
                        color: darkBlue,
                        errorBuilder: (c, e, s) =>
                            Icon(Icons.shield, size: mascotSize, color: darkBlue),
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
                                "Registrati per connetterti alla rete di emergenza",
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
                        //Continua con apple
                        _buildSocialButton(
                          text: "Continua con Apple",
                          icon: Icons.apple,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: buttonTextFontSize,
                        ),
                        SizedBox(height: verticalSpacing),

                        _buildSocialButton(
                          text: "Continua con Google",
                          imagePath: 'assets/googleIcon.png',
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          iconColor: Colors.red,
                          fontSize: buttonTextFontSize,
                        ),

                        SizedBox(height: verticalSpacing),
                        _buildSocialButton(
                          text: "Continua con Email",
                          icon: Icons.alternate_email,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          iconColor: darkBlue,
                          fontSize: buttonTextFontSize,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmailRegisterScreen(),
                            ),
                          ),
                        ),
                        SizedBox(height: verticalSpacing),

                        _buildSocialButton(
                          text: "Continua con Telefono",
                          icon: Icons.phone,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          iconColor: darkBlue,
                          fontSize: buttonTextFontSize,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PhoneRegisterScreen(),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.05),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Hai già un account? ",
                              style: TextStyle(color: Colors.white),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              ),

                              child: const Text(
                                "Login",
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

  Widget _buildSocialButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    String? imagePath,
    Color? iconColor,
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
            if (imagePath != null)
              Image.asset(imagePath, height: fontSize * 1.5)
            else if (icon != null)
              Icon(icon, color: iconColor ?? textColor, size: fontSize * 1.5),
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
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}