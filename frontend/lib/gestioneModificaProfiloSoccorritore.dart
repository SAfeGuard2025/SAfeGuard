import 'package:flutter/material.dart';

// Funzione helper per i colori
Color hexToColor(String code) {
  String hexCode = code.toUpperCase().replaceAll("#", "");
  if (hexCode.length == 6) {
    hexCode = "FF$hexCode";
  }
  return Color(int.parse(hexCode, radix: 16));
}

class GestioneModificaProfiloSoccorritore extends StatelessWidget {
  const GestioneModificaProfiloSoccorritore({super.key});

  @override
  Widget build(BuildContext context) {
    // Colori definiti
    final Color bgColor = hexToColor("12345a");      // Sfondo scuro
    final Color cardColor = hexToColor("0e2a48");    // Sfondo card
    final Color accentColor = hexToColor("ef923d");  // Arancione Cittadino
    final Color iconColor = hexToColor("e3c63d");    // Giallo Icona

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER (Freccia Indietro + Titolo) ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 30),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Icon(Icons.person_outline, color: iconColor, size: 40), // Icona Profilo
                    const SizedBox(width: 10),
                    const Text(
                      "Modifica\nProfilo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28, // Leggermente ridotto per evitare overflow
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              // --- 2. CARD CON I CAMPI DI TESTO ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Column(
                    children: [
                      // Avatar placeholder (opzionale)
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.camera_alt, size: 30, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Campi di input
                      const EditProfileField(label: "Nome", placeholder: "Mario"),
                      const EditProfileField(label: "Cognome", placeholder: "Rossi"),
                      const EditProfileField(label: "Email", placeholder: "mario.rossi@email.com"),
                      const EditProfileField(label: "Telefono", placeholder: "+39 333 1234567"),
                      const EditProfileField(label: "Indirizzo", placeholder: "Via Roma 1, Milano"),

                      const SizedBox(height: 30),

                      // Bottone Salva
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            // Logica di salvataggio
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Profilo aggiornato con successo!")),
                            );
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "SALVA MODIFICHE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET CAMPO DI TESTO PERSONALIZZATO ---
class EditProfileField extends StatelessWidget {
  final String label;
  final String placeholder;

  const EditProfileField({
    super.key,
    required this.label,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: Colors.black12,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white54, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}