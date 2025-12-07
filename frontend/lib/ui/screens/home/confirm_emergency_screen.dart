import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/emergency_provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/widgets/swipe_to_confirm.dart';
import 'package:frontend/ui/style/color_palette.dart';

import '../../widgets/sos_button.dart';

// Schermata di Conferma Emergenza (SOS)
class ConfirmEmergencyScreen extends StatelessWidget {
  const ConfirmEmergencyScreen({super.key});

  static const Color brightRed = ColorPalette.primaryBrightRed;

  @override
  Widget build(BuildContext context) {
    // Variabili per la responsività
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final bool isWideScreen = screenWidth > 600;

    // Dimensione dei font
    final double titleSize = isWideScreen ? 60 : 45;
    final double subTitleSize = isWideScreen ? 26 : 20;
    final double legalTextSize = isWideScreen ? 20 : 14;
    final double cancelTextSize = isWideScreen ? 35 : 24;

    // Larghezza slider
    final double sliderWidth = math.min(screenWidth * 0.85, 500.0);

    return Scaffold(
      backgroundColor: brightRed,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Immagine SOS
              Expanded(
                flex: 4,
                child: Center(
                  child: AspectRatio(aspectRatio: 1, child: _buildSosImage()),
                ),
              ),

              SizedBox(height: isWideScreen ? 40 : 20),

              // 2. Testi di Titolo e Istruzione
              Column(
                children: [
                  Text(
                    "Conferma SOS",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: titleSize,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Text(
                    "Swipe per mandare la tua \nposizione e allertare i soccorritori",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: subTitleSize,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // 3. Slider di Conferma
              Center(
                child: SwipeToConfirm(
                  width: sliderWidth,
                  height: isWideScreen ? 80 : 70,
                  onConfirm: () async {
                    try {
                      // 1. Recupero l'utente dall'AuthProvider
                      final authProvider = context.read<AuthProvider>();
                      final user = authProvider.currentUser;

                      // Controllo di sicurezza: se l'utente non è in memoria, blocco l'azione
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Errore: Utente non trovato. Effettua il login.",
                            ),
                            backgroundColor: Colors.black,
                          ),
                        );
                        return;
                      }

                      // 2. Estraggo i dati per il Database
                      final String userId = user.id.toString();
                      final String? userEmail = user.email;
                      final String? userPhone = user.telefono;

                      // Feedback visivo immediato
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Tentativo invio in corso..."),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      // 3. Chiamata al Provider passando TUTTI i dati
                      final success = await context
                          .read<EmergencyProvider>()
                          .sendInstantSos(
                        userId: userId,
                        email: userEmail,
                        phone: userPhone,
                        type: "SOS Generico", // Assicurati che questo testo sia gestito nel backend
                      );

                      // Controllo se il widget è ancora montato
                      if (!context.mounted) return;

                      // Invio di un messaggio che conferma la ricesione dell'SOS
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "SOS INVIATO! I soccorsi stanno arrivando.",
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                          ),
                        );

                        if (context.mounted) {
                          Navigator.of(context).pop(); // Torna alla Home
                        }

                        // Invio di un messaggio che avvisa il mancato invio dell'SOS
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Errore Invio! Controlla connessione.",
                            ),
                            backgroundColor: Colors.black,
                            duration: Duration(seconds: 4),
                          ),
                        );
                      }
                    } catch (e) {
                      // Gestione errori specifici (es. GPS disattivato)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString().replaceAll("Exception: ", ""),
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  },
                ),
              ),

              const Spacer(flex: 1),

              // 4. Footer (Info Legali e Annulla)
              Column(
                children: [
                  // Avviso legale (procurato allarme)
                  Text(
                    "Ricorda che il procurato allarme verso le autorità è\nperseguibile per legge ai sensi dell'art. 658 del c.p.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      fontSize: legalTextSize,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Pulsante Annulla
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Annulla",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: cancelTextSize,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper per il pulsante SOS
  Widget _buildSosImage() {
    // Restituisce direttamente il widget disegnato
    return const SosButton();
  }
}
