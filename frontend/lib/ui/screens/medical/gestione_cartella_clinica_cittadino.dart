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
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 700;

    // Colori dinamici in base al ruolo
    final Color cardColor = isRescuer
        ? ColorPalette.cardDarkOrange
        : ColorPalette.backgroundMidBlue;
    final Color bgColor = isRescuer
        ? ColorPalette.primaryOrange
        : ColorPalette.backgroundDarkBlue;

    // VARIABILI DI DIMENSIONE UNIFORMATE
    final double titleSize = isWideScreen ? 50 : 28;
    final double iconSize = isWideScreen ? 60 : 40;
    final double buttonTextSize = isWideScreen ? 22 : 18;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: isWideScreen ? 36 : 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.assignment_ind_outlined,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      const SizedBox(width: 15),
                      // Titolo su una riga
                      Text(
                        "Cartella Clinica",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isWideScreen ? 40.0 : 20.0),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            // 1. Condizioni Mediche
                            _buildMenuButton(
                              context,
                              label: "Condizioni Mediche",
                              textSize: buttonTextSize,
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
                              textSize: buttonTextSize,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AllergieScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),

                            // 3. Medicinali
                            _buildMenuButton(
                              context,
                              label: "Medicinali",
                              textSize: buttonTextSize,
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
                              textSize: buttonTextSize,
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
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Helper: Pulsante di Navigazione
  Widget _buildMenuButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    required double textSize,
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
                style: TextStyle(
                  color: Colors.black,
                  fontSize: textSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
                size: textSize + 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
