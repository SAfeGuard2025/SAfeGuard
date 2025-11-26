import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/screens/home/home_screen.dart';

class EmailRegisterScreen extends StatefulWidget {
  const EmailRegisterScreen({super.key});

  @override
  State<EmailRegisterScreen> createState() => _EmailRegisterScreenState();
}

class _EmailRegisterScreenState extends State<EmailRegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _repeatPassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final Color buttonColor = const Color(0xFF0A2540);

    //HEADER DELL'APP
    return Scaffold(
      extendBodyBehindAppBar: true,
      //BARRA SUPERIORE DOVE CI SONO: ACCESSO - ICONA - SKIP
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      //BODY
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50),

                  //TESTO
                  const Text(
                    "Inserisci i tuoi dati",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 100),

                  //CAMPO DI TESTO -- EMAIL
                  _buildTextField("Email", _emailController),
                  const SizedBox(height: 20),

                  //CAMPO DI TESTO -- PASSWORD
                  _buildTextField(
                    "Password",
                    _passController,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),

                  //CAMPO DI TESTO - RIPETI PASSWORD
                  _buildTextField(
                    "Ripeti Password",
                    _repeatPassController,
                    isPassword: true,
                  ),

                  //MESSAGGIO DI ERRORE
                  if (authProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const Spacer(),

                  //BOX DEL CONTROLLO CON MESSAGGI DI ERRORE
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              // CONTROLLO BASE DELLA PASSWORD
                              if (_passController.text !=
                                  _repeatPassController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Le password non coincidono"),
                                  ),
                                );
                                return;
                              }
                              bool success = await authProvider.register(
                                _emailController.text,
                                _passController.text,
                              );

                              //REINDIRIZZAMENTO SE IL CONTROLLO VA BENE
                              if (success && mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },

                      //PULSANTE CONTINUA
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
                              "CONTINUA",
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  //INSERIRE IN UN FILE A PARTE
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
