import 'package:flutter/material.dart';

// --- IMPORT DELLE SCHERMATE FUNZIONALI ---
import 'package:frontend/ui/screens/medical/condizioni_mediche_screen.dart';
import 'package:frontend/ui/screens/medical/allergie_screen.dart';
import 'package:frontend/ui/screens/medical/medicinali_screen.dart';
import 'package:frontend/ui/screens/medical/contatti_emergenza_screen.dart';

class GestioneCartellaClinicaCittadino extends StatelessWidget {
  const GestioneCartellaClinicaCittadino({super.key});

  @override
  Widget build(BuildContext context) {
    // Colori standard definiti
    const Color bgColor = Color(0xFF12345A);
    const Color cardColor = Color(0xFF0E2A48);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // --- 1. HEADER (Titolo) ---
            // Nota: Rimosso pulsante Back perché questa è una Root Page della Navbar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                      Icons.assignment_ind_outlined,
                      color: Colors.white70,
                      size: 80
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    "Cartella\nClinica",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- 2. CARD CENTRALE CON MENU ---
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Condizioni Mediche
                        _buildMenuButton(
                          context,
                          label: "Condizioni Mediche",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CondizioniMedicheScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // 2. Allergie
                        _buildMenuButton(
                          context,
                          label: "Allergie",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllergieScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // 3. Medicinali
                        _buildMenuButton(
                          context,
                          label: "Medicinali",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MedicinaliScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // 4. Contatti di emergenza
                        _buildMenuButton(
                          context,
                          label: "Contatti di emergenza",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ContattiEmergenzaScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Spazio finale per non attaccare la card alla bottom bar
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PULSANTE MENU ---
  Widget _buildMenuButton(BuildContext context, {required String label, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}