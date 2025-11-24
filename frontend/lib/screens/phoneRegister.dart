import 'package:flutter/material.dart';

class PhoneRegister extends StatelessWidget {
  const PhoneRegister({super.key});

  @override
  Widget build(BuildContext context) {
    // Colore blu scuro del brand
    final Color darkBlue = const Color(0xFF041528);
    // Colore del bottone (un po' più chiaro per risaltare, o lo stesso)
    final Color buttonColor = const Color(0xFF0A2540);

    return Scaffold(
      // AppBar trasparente per vedere lo sfondo dietro
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Freccia indietro bianca
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: Stack(
        children: [
          // --- LAYER 1: SFONDO ---
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF041528), // Colore di base per sicurezza
              image: DecorationImage(
                // Assicurati di avere questa immagine in assets!
                image: AssetImage('assets/backgroundBubbles3.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // --- LAYER 2: CONTENUTO ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Allarga tutto
                children: [
                  const SizedBox(height: 50),

                  // TITOLO
                  const Text(
                    "Inserisci il numero di\ntelefono",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.2, // Spaziatura righe
                    ),
                  ),

                  const SizedBox(height: 100), // Spazio prima dei campi

                  // CAMPO EMAIL
                  _buildTextField("+39 333 1234567"),
                  const SizedBox(height: 20),

                  // CAMPO PASSWORD
                  _buildTextField("Password", isPassword: true),
                  const SizedBox(height: 20),

                  // CAMPO RIPETI PASSWORD
                  _buildTextField("Ripeti Password", isPassword: true),

                  const Spacer(), // Spinge il bottone in fondo

                  // BOTTONE CONTINUA
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // Azione continua
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor, // Sfondo del bottone
                        foregroundColor: Colors.white, // Testo bianco
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        // Un po' di bordo per farlo risaltare sullo sfondo scuro (opzionale)
                        side: const BorderSide(color: Colors.white12, width: 1),
                      ),
                      child: const Text(
                        "REGISTRATI",
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100), // Margine dal fondo
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper per i campi di testo bianchi ---
  Widget _buildTextField(String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword, // Nasconde il testo se è una password
      style: const TextStyle(color: Colors.black), // Testo che scrivi è nero
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white, // Sfondo bianco
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Bordi molto arrotondati
          borderSide: BorderSide.none, // Nessun bordo nero
        ),
      ),
    );
  }
}