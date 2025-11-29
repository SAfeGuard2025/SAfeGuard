import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/screens/auth/verification_screen.dart';
import 'package:frontend/ui/style/color_palette.dart';

class EmailRegisterScreen extends StatefulWidget {
  const EmailRegisterScreen({super.key});

  @override
  State<EmailRegisterScreen> createState() => _EmailRegisterScreenState();
}

class _EmailRegisterScreenState extends State<EmailRegisterScreen> {
  // 1. Chiave globale per validare tutto il form insieme
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _repeatPassController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  bool _isPasswordVisible = false;
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Variabili per il layout responsive
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
    final double largeSpacing = screenHeight * 0.05;

    final authProvider = Provider.of<AuthProvider>(context);
    final Color buttonColor = ColorPalette.primaryDarkButtonBlue;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: Stack(
        children: [
          // Sfondo con immagine
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: ColorPalette.backgroundDeepBlue,
              image: DecorationImage(
                image: AssetImage('assets/backgroundBubbles3.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SingleChildScrollView(
                //  FORM: Avvolge i campi per gestire la validazione
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: verticalPadding),

                      Text(
                        "Registrazione",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      SizedBox(height: largeSpacing),

                      _buildTextFormField(
                        "Nome",
                        _nameController,
                        fontSize: contentFontSize,
                        validator: (value) => value == null || value.isEmpty
                            ? "Inserisci il nome"
                            : null,
                      ),
                      SizedBox(height: smallSpacing),

                      _buildTextFormField(
                        "Cognome",
                        _surnameController,
                        fontSize: contentFontSize,
                        validator: (value) => value == null || value.isEmpty
                            ? "Inserisci il cognome"
                            : null,
                      ),
                      SizedBox(height: smallSpacing),

                      _buildTextFormField(
                        "Email",
                        _emailController,
                        fontSize: contentFontSize,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Inserisci l'email";
                          return null;
                        },
                      ),
                      SizedBox(height: smallSpacing),

                      _buildTextFormField(
                        "Password",
                        _passController,
                        isPassword: true,
                        fontSize: contentFontSize,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Inserisci la password";
                          if (value.length < 6) return "Minimo 6 caratteri";
                          if (value.length > 12) return "Massimo 12 caratteri";
                          if (!RegExp(
                            r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#%^&*(),.?":{}|<>_])',
                          ).hasMatch(value)) {
                            return "Serve: 1 Maiuscola, 1 Numero, 1 Speciale";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: smallSpacing),

                      _buildTextFormField(
                        "Ripeti Password",
                        _repeatPassController,
                        isPassword: true,
                        fontSize: contentFontSize,
                        validator: (value) {
                          if (value != _passController.text)
                            return "Le password non coincidono";
                          return null;
                        },
                      ),

                      // Messaggio errore generico dal Server (es. Email già usata)
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

                      SizedBox(height: largeSpacing),

                      SizedBox(
                        height: referenceSize * 0.12,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () async {
                                  //Validazione degli elementi
                                  if (_formKey.currentState!.validate()) {
                                    final navigator = Navigator.of(context);

                                    // Chiamata al Provider
                                    bool success = await authProvider.register(
                                      _emailController.text.trim(),
                                      _passController.text,
                                      _nameController.text.trim(),
                                      _surnameController.text.trim(),
                                    );

                                    // Navigazione se successo
                                    if (success && context.mounted) {
                                      navigator.push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const VerificationScreen(),
                                        ),
                                      );
                                    }
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
                                  "CONTINUA",
                                  style: TextStyle(
                                    fontSize: referenceSize * 0.05,
                                    fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }

  //Widget per gli errori nei campi
  Widget _buildTextFormField(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    double contentVerticalPadding = 20,
    required double fontSize,
    String? Function(String?)? validator,
  }) {
    bool obscureText = isPassword ? !_isPasswordVisible : false;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
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

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),

        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          backgroundColor: Colors.black54,
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
