import 'package:flutter/material.dart';
import 'package:frontend/ui/screens/auth/verification_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/screens/home/home_screen.dart';
import 'package:frontend/ui/style/color_palette.dart';
import '../../widgets/bubble_background.dart';

// Schermata di Login tramite Email e Password.
class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  // Controller per i campi di testo
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isPasswordVisible = false;
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
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

    final double titleFontSize = referenceSize * 0.075;
    final double contentFontSize = referenceSize * 0.045;
    final double verticalPadding = screenHeight * 0.04;
    final double smallSpacing = screenHeight * 0.015;

    final authProvider = Provider.of<AuthProvider>(context);
    final Color buttonColor = ColorPalette.primaryDarkButtonBlue;

    return Scaffold(
      // 1. IMPORTANTE: Impedisce allo sfondo di deformarsi/salire quando esce la tastiera
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,

      // Imposta un colore di sicurezza per evitare flash bianchi
      backgroundColor: ColorPalette.backgroundDeepBlue,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: Stack(
        // 2. Assicura che lo Stack occupi sempre tutto lo spazio disponibile
        fit: StackFit.expand,
        children: [
          // Sfondo: Ora rimarrà fisso e a tutto schermo
          const Positioned.fill(
            child: BubbleBackground(type: BubbleType.type3),
          ),

          // Contenuto Principale
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              // Gestione scroll e tastiera
              child: SingleChildScrollView(
                // 3. Aggiunta padding per spingere il contenuto su quando esce la tastiera
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: verticalPadding),

                    Text(
                      "Accedi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.10),

                    // Campo Email
                    _buildTextField(
                      "Email",
                      _emailController,
                      isPassword: false,
                      contentVerticalPadding: 16,
                      fontSize: contentFontSize,
                    ),
                    SizedBox(height: smallSpacing),

                    // Campo Password
                    _buildTextField(
                      "Password",
                      _passController,
                      isPassword: true,
                      contentVerticalPadding: 16,
                      fontSize: contentFontSize,
                    ),

                    if (authProvider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    SizedBox(height: screenHeight * 0.15),

                    // Bottone Accedi
                    SizedBox(
                      height: referenceSize * 0.12,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                final navigator = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);

                                if (_emailController.text.isEmpty ||
                                    _passController.text.isEmpty) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Inserisci email e password",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                String result = await authProvider.login(
                                  _emailController.text.trim(),
                                  _passController.text,
                                );
                                // 2. Se il login ha successo, naviga alla Home e rimuove tutte le schermate precedenti
                                if (result == 'success') {
                                  // Login OK -> Home
                                  navigator.pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                    (route) => false,
                                  );
                                } else if (result == 'verification_needed') {
                                  // Login Bloccato -> Verifica OTP
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Account non verificato. Inserisci il codice inviato via email.",
                                      ),
                                    ),
                                  );
                                  navigator.push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const VerificationScreen(),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          side: const BorderSide(
                            color: Colors.white12,
                            width: 1,
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "ACCEDI",
                                style: TextStyle(
                                  fontSize: referenceSize * 0.07,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: verticalPadding),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper per costruire i campi di testo
  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    required bool isPassword,
    double contentVerticalPadding = 20,
    required double fontSize,
  }) {
    // Determina se il testo deve essere oscurato
    bool obscureText = isPassword ? !_isPasswordVisible : false;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.black, fontSize: fontSize),

      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey, fontSize: fontSize),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 25,
          vertical: contentVerticalPadding,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),

        // Icona per la visibilità della password
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                  size: fontSize * 1.5,
                ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
      ),
    );
  }
}
