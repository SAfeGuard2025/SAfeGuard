import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';

import 'package:frontend/ui/screens/medical/condizioni_mediche_screen.dart';
import 'package:frontend/ui/screens/medical/allergie_screen.dart';
import 'package:frontend/ui/screens/medical/medicinali_screen.dart';
import 'package:frontend/ui/screens/medical/contatti_emergenza_screen.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Schermata Gestione Cartella Clinica Cittadino
// Menu principale per accedere alle sezioni dei dati medici personali.
class GestioneCartellaClinicaCittadino extends StatelessWidget {
  const GestioneCartellaClinicaCittadino({super.key});

  @override
  Widget build(BuildContext context) {
    // Ottiene il ruolo dell'utente dal provider di autenticazione
    final isRescuer = context.watch<AuthProvider>().isRescuer;

    // Colori dinamici in base al ruolo
    final Color cardColor = isRescuer
        ? ColorPalette.cardDarkOrange
        : ColorPalette.backgroundMidBlue;
    final Color bgColor = isRescuer
        ? ColorPalette.primaryOrange
        : ColorPalette.backgroundDarkBlue;

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        // Rimosso il leading per inserire l'icona nel titolo e applicare padding uniforme
        automaticallyImplyLeading: false,

        // Title Widget con icona, titolo e tasto indietro
        title: Padding(
          padding: const EdgeInsets.only(left: 0, right: 16.0, top: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tasto Indietro
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(width: 10), // Spazio tra freccia e icona
              // 2. Icona e Titolo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.assignment_ind_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    "Cartella\nClinica",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        centerTitle: false, // Necessario per allineare il Row a sinistra
        toolbarHeight:
            80.0, // Aumenta l'altezza della barra per il padding verticale di 20.0
      ),

      // Contenuto della card
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30.0,
                      horizontal: 20.0,
                    ),
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
                                  builder: (context) =>
                                      const CondizioniMedicheScreen(),
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
                                  builder: (context) =>
                                      const MedicinaliScreen(),
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
                                  builder: (context) =>
                                      const ContattiEmergenzaScreen(),
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
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Widget Helper: Pulsante di Navigazione
  Widget _buildMenuButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
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
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
