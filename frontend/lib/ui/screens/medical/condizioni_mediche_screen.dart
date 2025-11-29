import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/medical_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Schermata Gestione Condizioni Mediche
// Permette all'utente di attivare/disattivare specifiche condizioni/disabilità.
class CondizioniMedicheScreen extends StatefulWidget {
  const CondizioniMedicheScreen({super.key});

  @override
  State<CondizioniMedicheScreen> createState() =>
      _CondizioniMedicheScreenState();
}

class _CondizioniMedicheScreenState extends State<CondizioniMedicheScreen> {
  @override
  void initState() {
    super.initState();
    // Carica i dati dal MedicalProvider all'avvio della schermata
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicalProvider>(context, listen: false).loadCondizioni();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = ColorPalette.backgroundMidBlue;
    const Color cardColor = ColorPalette.backgroundDarkBlue;
    const Color activeSwitchColor = ColorPalette.primaryOrange;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header con bottone indietro
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Icona e titolo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person_3, color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    "Condizioni\nMediche",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Card con la lista degli switch
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),

                  // Consumer: Ascolta le modifiche nel MedicalProvider
                  child: Consumer<MedicalProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Ottiene l'oggetto Condizioni Mediche
                      final cond = provider.condizioni;

                      return ListView(
                        children: [
                          // Switch 1: Disabilità motorie
                          _buildSwitchTile(
                            "Disabilità motorie",
                            cond.disabilitaMotorie,
                            (val) {
                              provider.updateCondizioni(
                                // Crea un nuovo oggetto CondizioniMediche con il campo aggiornato
                                cond.copyWith(disabilitaMotorie: val),
                              );
                            },
                            activeSwitchColor,
                          ),
                          const SizedBox(height: 10),

                          // Switch 2: Disabilità visive
                          _buildSwitchTile(
                            "Disabilità visive",
                            cond.disabilitaVisive,
                            (val) {
                              provider.updateCondizioni(
                                cond.copyWith(disabilitaVisive: val),
                              );
                            },
                            activeSwitchColor,
                          ),
                          const SizedBox(height: 10),

                          // Switch 3: Disabilità uditive
                          _buildSwitchTile(
                            "Disabilità uditive",
                            cond.disabilitaUditive,
                            (val) {
                              provider.updateCondizioni(
                                cond.copyWith(disabilitaUditive: val),
                              );
                            },
                            activeSwitchColor,
                          ),
                          const SizedBox(height: 10),

                          // Switch 4: Disabilità intellettive
                          _buildSwitchTile(
                            "Disabilità intellettive",
                            cond.disabilitaIntellettive,
                            (val) {
                              provider.updateCondizioni(
                                cond.copyWith(disabilitaIntellettive: val),
                              );
                            },
                            activeSwitchColor,
                          ),
                          const SizedBox(height: 10),

                          // Switch 5: Disabilità psichiche
                          _buildSwitchTile(
                            "Disabilità psichiche",
                            cond.disabilitaPsichiche,
                            (val) {
                              provider.updateCondizioni(
                                cond.copyWith(disabilitaPsichiche: val),
                              );
                            },
                            activeSwitchColor,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  //Widget Helper: Tile con Switch
  Widget _buildSwitchTile(
    String title,
    bool value,
    Function(bool) onChanged,
    Color activeColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Transform.scale(
            scale: 1.1,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: activeColor,
              activeTrackColor: Colors.white.withValues(alpha: 0.3),
              inactiveThumbColor: Colors.grey.shade300,
              inactiveTrackColor: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}
