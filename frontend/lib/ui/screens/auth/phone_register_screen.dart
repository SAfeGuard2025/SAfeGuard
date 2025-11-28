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
              child: SingleChildScrollView( // Aggiunto per evitare overflow con la tastiera
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      "Registrati col numero",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 40),

                    _buildTextField("Nome", _nameController),
                    const SizedBox(height: 15),

                    _buildTextField("Cognome", _surnameController),
                    const SizedBox(height: 15),

                    // INPUT TELEFONO
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
                    const SizedBox(height: 20),

                    // INPUT PASSWORD
                    _buildTextField("Password", _passController, isPassword: true),
                    const SizedBox(height: 20),

                    // INPUT RIPETI PASSWORD
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

                    const SizedBox(height: 40), // Spaziatura prima del bottone

                    // BOTTONE REGISTRATI
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                          final navigator = Navigator.of(context);
                          final phone = _phoneController.text.trim();
                          final nome = _nameController.text.trim();
                          final cognome = _surnameController.text.trim();

                          if (phone.isEmpty || phone.length < 5) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inserisci un numero valido")));
                            return;
                          }
                          if (nome.isEmpty || cognome.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nome e Cognome obbligatori")));
                            return;
                          }
                          if (_passController.text != _repeatPassController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Le password non coincidono")));
                            return;
                          }
                          if (_passController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inserisci una password")));
                            return;
                          }

                          bool success = await authProvider.startPhoneAuth(
                              phone,
                              password: _passController.text, // Passiamo la password!
                              nome: _passController.text,
                              cognome: _passController.text
                          );

                          if (success && mounted) {
                            navigator.push(
                              MaterialPageRoute(
                                builder: (context) => const VerificationScreen(),
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
                          side: const BorderSide(color: Colors.white12, width: 1),
                        ),
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "REGISTRATI",
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
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

  // Widget Helper per i campi di testo
  Widget _buildTextField(
      String hint,
      TextEditingController controller, {
        bool isPassword = false,
      }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}