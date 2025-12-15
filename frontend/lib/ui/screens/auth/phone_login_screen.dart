import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/screens/home/home_screen.dart';
import 'package:frontend/ui/style/color_palette.dart';
import '../../widgets/bubble_background.dart';
import 'package:frontend/ui/screens/auth/verification_screen.dart';

// Schermata di Login tramite Numero di Telefono e Password.
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  // Controller con valore iniziale preimpostato per il prefisso italiano
  final TextEditingController _phoneController = TextEditingController(
    text: "+39",
  );
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

    // Accesso all'AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final Color buttonColor = ColorPalette.primaryDarkButtonBlue;

    return Scaffold(
      // 1. BLOCCA IL RIDIMENSIONAMENTO DELLO SFONDO
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: ColorPalette.backgroundDeepBlue, // Colore di sicurezza
      // Header con bottone indietro
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: Stack(
        // 2. FORZA LO STACK A RIEMPIRE LO SCHERMO
        fit: StackFit.expand,
        children: [
          // Sfondo
          const Positioned.fill(
            child: BubbleBackground(type: BubbleType.type3),
          ),

          // Contenuto principale
          SafeArea(
            child: Column(
              children: [
                // 1. PARTE SCORREVOLE (Titolo + Campi)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
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

                        // Input telefono
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: contentFontSize,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: contentFontSize,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: smallSpacing),

                        // Input Password
                        _buildTextField(
                          "Password",
                          _passController,
                          isPassword: true,
                          contentVerticalPadding: 16,
                          fontSize: contentFontSize,
                        ),

                        // Messaggio di errore del provider
                        if (authProvider.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              authProvider.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        // Spazio extra per evitare che l'ultimo campo sia coperto
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // 2. PARTE FISSA (Bottone CONTINUA)
                Container(
                  padding: EdgeInsets.only(
                    left: 25.0,
                    right: 25.0,
                    top: 10.0,
                    // Gestione padding tastiera
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: SizedBox(
                    height: referenceSize * 0.12,
                    width: 200.0,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              final navigator = Navigator.of(context);
                              final messenger = ScaffoldMessenger.of(context);
                              final phone = _phoneController.text.trim();
                              final password = _passController.text;

                              if (phone.isEmpty || password.isEmpty) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Inserisci telefono e password",
                                    ),
                                  ),
                                );
                                return;
                              }

                              // Gestione login
                              String result = await authProvider.loginPhone(
                                phone,
                                password,
                              );

                              if (!context.mounted) return;

                              if (result == 'success') {
                                // CASO 1: Login Riuscito -> Home
                                navigator.pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                  (route) => false,
                                );
                              } else if (result == 'verification_needed') {
                                // CASO 2: Non Verificato -> Schermata OTP
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Account non verificato. Inserisci il codice OTP inviato.",
                                    ),
                                    backgroundColor: Colors.orange,
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

                      // Stile del Bottone
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: const BorderSide(color: Colors.white12, width: 1),
                      ),
                      // Contenuto del bottone
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "CONTINUA",
                              style: TextStyle(
                                fontSize: referenceSize * 0.05,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
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

  // Widget Helper per costruire i campi di testo
  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    required bool isPassword,
    double contentVerticalPadding = 20,
    required double fontSize,
  }) {
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
