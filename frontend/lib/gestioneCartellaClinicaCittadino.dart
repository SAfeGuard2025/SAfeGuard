import 'package:flutter/material.dart';
import 'package:frontend/gestioneCondizioniMedicheCittadino.dart'; // O il percorso corretto
import 'package:frontend/gestioneCartellaClinicaCittadino.dart';
import 'package:frontend/gestioneMedicinaliCittadino.dart';
import 'package:frontend/gestioneAllergieCittadino.dart';
import 'package:frontend/gestioneContattiEmergenzaCittadino.dart';

import 'package:flutter/material.dart';

// Assicurati di importare le tue pagine qui sotto se sono in file separati
// import 'condizioni_mediche_screen.dart';
// import 'allergie_screen.dart';
// import 'medicinali_screen.dart';
// import 'contatti_emergenza_screen.dart';

// Helper per i colori
Color hexToColor(String code) {
  String hexCode = code.toUpperCase().replaceAll("#", "");
  if (hexCode.length == 6) {
    hexCode = "FF$hexCode";
  }
  return Color(int.parse(hexCode, radix: 16));
}

class GestioneCartellaClinicaCittadino extends StatelessWidget {
  const GestioneCartellaClinicaCittadino({super.key});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = hexToColor("12345a");
    final Color cardColor = hexToColor("0e2a48");
    final Color navBarColor = hexToColor("0e2a48");

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Icona e Titolo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment_ind_outlined, color: Colors.white70, size: 80),
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

            // --- 2. CARD CENTRALE CON NAVIGAZIONE ---
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
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

            const SizedBox(height: 20),
          ],
        ),
      ),

      // --- 3. BOTTOM NAV BAR ---
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20.0),
        height: 70,
        decoration: BoxDecoration(
          color: navBarColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home_outlined, color: Colors.white, size: 30),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.medical_information, color: Colors.white, size: 30), // Icona piena per indicare attivo
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.map_outlined, color: Colors.white, size: 30),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white, size: 30),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 30),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PULSANTE ---
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