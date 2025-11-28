import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/screens/auth/verification_screen.dart';

class PhoneRegisterScreen extends StatefulWidget {
  const PhoneRegisterScreen({super.key});

  @override
  State<PhoneRegisterScreen> createState() => _PhoneRegisterScreenState();
}

class _PhoneRegisterScreenState extends State<PhoneRegisterScreen> {
  final TextEditingController _phoneController = TextEditingController(text: "+39");
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
                    const SizedBox(height: 30),
                    const Text(
                      "Registrazione",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // CAMPO NOME
                    _buildTextField("Nome", _nameController, isPassword: false),
                    const SizedBox(height: 15),

                    // CAMPO COGNOME
                    _buildTextField("Cognome", _surnameController, isPassword: false),
                    const SizedBox(height: 15),

                    // INPUT TELEFONO (non ha suffix icon)
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "+39 ...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // INPUT PASSWORD (Ora usa _buildTextField modificato)
                    _buildTextField("Password", _passController, isPassword: true),
                    const SizedBox(height: 15),

                    // INPUT RIPETI PASSWORD (Ora usa _buildTextField modificato)
                    _buildTextField("Ripeti Password", _repeatPassController, isPassword: true),

                    if (authProvider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          authProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ),

                    const SizedBox(height: 30),

                    // BOTTONE REGISTRATI
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                          final navigator = Navigator.of(context);
                          final phone = _phoneController.text.trim().replaceAll(' ', ''); // Pulizia spazi
                          final nome = _nameController.text.trim();
                          final cognome = _surnameController.text.trim();
                          final password = _passController.text;

                          if (phone.isEmpty || phone.length < 5) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inserisci un numero valido")));
                            return;
                          }
                          if (nome.isEmpty || cognome.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nome e Cognome obbligatori")));
                            return;
                          }
                          if (password != _repeatPassController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Le password non coincidono")));
                            return;
                          }
                          if (password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inserisci una password")));
                            return;
                          }

                          bool success = await authProvider.startPhoneAuth(
                              phone,
                              password: password,
                              nome: nome,
                              cognome: cognome
                          );

                          if (success && mounted) {
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
                            : const Text("REGISTRATI", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET CAMPO DI TESTO
  Widget _buildTextField(String hint, TextEditingController controller, {required bool isPassword}) {
    bool obscureText = isPassword ? !_isPasswordVisible : false;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),

        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: _togglePasswordVisibility, // Chiama la funzione che fa setState
        )
            : null,
      ),
    );
  }
}