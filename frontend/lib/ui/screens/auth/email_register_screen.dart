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
                      "Inserisci i tuoi dati",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // NOME E COGNOME
                    _buildTextField("Nome", _nameController),
                    const SizedBox(height: 15),
                    _buildTextField("Cognome", _surnameController),
                    const SizedBox(height: 15),

                    _buildTextField("Email", _emailController),
                    const SizedBox(height: 15),

                    _buildTextField("Password", _passController, isPassword: true),
                    const SizedBox(height: 15),

                    _buildTextField("Ripeti Password", _repeatPassController, isPassword: true),

                    if (authProvider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 30),

                    SizedBox(
                      height: 55,
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
                            : const Text("CONTINUA", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }
}