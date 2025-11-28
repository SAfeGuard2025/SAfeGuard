import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/screens/auth/verification_screen.dart';

class EmailRegisterScreen extends StatefulWidget {
  const EmailRegisterScreen({super.key});

  @override
  State<EmailRegisterScreen> createState() => _EmailRegisterScreenState();
}

class _EmailRegisterScreenState extends State<EmailRegisterScreen> {
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
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final double referenceSize = screenHeight < screenWidth ? screenHeight : screenWidth;
    final double titleFontSize = referenceSize * 0.075;
    final double contentFontSize = referenceSize * 0.045;
    final double verticalPadding = screenHeight * 0.04;
    final double smallSpacing = screenHeight * 0.015;
    final double largeSpacing = screenHeight * 0.05;

    final authProvider = Provider.of<AuthProvider>(context);
    final Color buttonColor = const Color(0xFF0A2540);

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
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF041528),
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

                    // Campi di testo
                    _buildTextField("Nome", _nameController, isPassword: false, contentVerticalPadding: 12, fontSize: contentFontSize),
                    SizedBox(height: smallSpacing),
                    _buildTextField("Cognome", _surnameController, isPassword: false, contentVerticalPadding: 12, fontSize: contentFontSize),
                    SizedBox(height: smallSpacing),

                    _buildTextField("Email", _emailController, isPassword: false, contentVerticalPadding: 12, fontSize: contentFontSize),
                    SizedBox(height: smallSpacing),

                    _buildTextField("Password", _passController, isPassword: true, contentVerticalPadding: 12, fontSize: contentFontSize),
                    SizedBox(height: smallSpacing),

                    _buildTextField("Ripeti Password", _repeatPassController, isPassword: true, contentVerticalPadding: 12, fontSize: contentFontSize),

                    if (authProvider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
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
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);

                          if (_passController.text != _repeatPassController.text) {
                            messenger.showSnackBar(const SnackBar(content: Text("Le password non coincidono")));
                            return;
                          }

                          if (_nameController.text.isEmpty || _surnameController.text.isEmpty) {
                            messenger.showSnackBar(const SnackBar(content: Text("Nome e Cognome obbligatori")));
                            return;
                          }

                          bool success = await authProvider.register(
                              _emailController.text.trim(),
                              _passController.text,
                              _nameController.text.trim(),
                              _surnameController.text.trim()
                          );

                          if (success && context.mounted) {
                            navigator.push(MaterialPageRoute(builder: (context) => const VerificationScreen()));
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          side: const BorderSide(color: Colors.white12, width: 1),
                        ),
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          "CONTINUA",
                          style: TextStyle(
                              fontSize: referenceSize * 0.05,
                              fontWeight: FontWeight.bold
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

  // Widget campo di testo
  Widget _buildTextField(String hint, TextEditingController controller, {required bool isPassword, double contentVerticalPadding = 20, required double fontSize}) {
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
        contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: contentVerticalPadding),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),

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