import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/screens/auth/verification_screen.dart';
import 'package:frontend/ui/style/color_palette.dart';
import '../../widgets/bubble_background.dart';

// Schermata di Registrazione tramite Email e Password
class EmailRegisterScreen extends StatefulWidget {
  const EmailRegisterScreen({super.key});

  @override
  State<EmailRegisterScreen> createState() => _EmailRegisterScreenState();
}

class _EmailRegisterScreenState extends State<EmailRegisterScreen> {
  // 1. Chiave globale per validare tutto il form insieme
  final _formKey = GlobalKey<FormState>();

  // Controller per i campi di testo
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
    final double largeSpacing = screenHeight * 0.05;

    // Accesso all'AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final Color buttonColor = ColorPalette.primaryDarkButtonBlue;

    return Scaffold(
      // 1. BLOCCA IL RIDIMENSIONAMENTO DELLO SFONDO
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: ColorPalette.backgroundDeepBlue,

      // Header
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
          // Sfondo fisso
          const Positioned.fill(
            child: BubbleBackground(type: BubbleType.type3),
          ),

          // Contenuto
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    // Widget Form: Avvolge i campi per gestire la validazione unificata
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
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
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? "Inserisci il nome"
                                  : null,
                            ),
                            SizedBox(height: smallSpacing),

                            _buildTextFormField(
                              "Cognome",
                              _surnameController,
                              fontSize: contentFontSize,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? "Inserisci il cognome"
                                  : null,
                            ),
                            SizedBox(height: smallSpacing),

                            _buildTextFormField(
                              "Email",
                              _emailController,
                              fontSize: contentFontSize,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Inserisci l'email";
                                }
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
                                if (value == null || value.isEmpty) {
                                  return "Inserisci la password";
                                }
                                if (value.length < 6) {
                                  return "Minimo 6 caratteri";
                                }
                                if (value.length > 12) {
                                  return "Massimo 12 caratteri";
                                }
                                // Regex per almeno 1 Maiuscola, 1 Numero, 1 Carattere Speciale
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
                                if (value != _passController.text) {
                                  return "Le password non coincidono";
                                }
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

                            // Spazio extra in fondo per non coprire l'ultimo campo
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. GESTIONE SPAZIO TASTIERA MANUALE (Applicata al contenitore del bottone)
                Container(
                  padding: EdgeInsets.only(
                    left: 25.0,
                    right: 25.0,
                    top: 10.0,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: SizedBox(
                    height: referenceSize * 0.12,
                    width: 200.0,

                    // Bottone Continua
                    child: ElevatedButton(
                      // Disabilita il bottone se in caricamento
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              // 1. Esegue la validazione su tutti i campi del Form
                              if (_formKey.currentState!.validate()) {
                                final navigator = Navigator.of(context);

                                // 2. Chiamata al metodo register dell'AuthProvider
                                bool success = await authProvider.register(
                                  _emailController.text.trim(),
                                  _passController.text,
                                  _nameController.text.trim(),
                                  _surnameController.text.trim(),
                                );

                                // 3. Navigazione se la registrazione (e l'invio OTP) ha successo
                                if (success && context.mounted) {
                                  navigator.push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          // Naviga alla schermata per inserire l'OTP
                                          const VerificationScreen(),
                                    ),
                                  );
                                }
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
                              "REGISTRA",
                              style: TextStyle(
                                fontSize: referenceSize * 0.05,
                                fontWeight: FontWeight.bold,
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

  // Widget Helper per costruire i campi di testo con validazione (TextFormField)
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
      validator: validator, // Passa la funzione di validazione
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

        // Stile del bordo normale
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

        // Stile del testo di errore
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          backgroundColor: Colors.black54,
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
