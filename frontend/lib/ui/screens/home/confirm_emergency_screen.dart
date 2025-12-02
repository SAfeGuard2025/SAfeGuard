import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/swipe_to_confirm.dart';
import 'package:frontend/ui/style/color_palette.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/emergency_provider.dart';
import 'package:frontend/providers/auth_provider.dart';

import '../../widgets/sos_button.dart';

// Schermata di Conferma Emergenza (SOS)
// Presenta un'interfaccia ad alto contrasto (rosso) e richiede uno swipe per confermare l'allarme.
class ConfirmEmergencyScreen extends StatelessWidget {
  const ConfirmEmergencyScreen({super.key});

  static const Color brightRed = ColorPalette.primaryBrightRed;

  // --- LOGICA DI INVIA SOS E GESTIONE DEL FEEDBACK ---
  Future<void> _handleConfirmSos(BuildContext context) async {
    // Otteniamo i Provider necessari
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final emergencyProvider = Provider.of<EmergencyProvider>(context, listen: false);

    // Dati essenziali per l'API (Simulazione GPS e Token)
    // NOTA: In produzione, questo sarebbe sostituito da un servizio di geolocalizzazione reale.
    const double simulatedLat = 40.76;
    const double simulatedLng = 14.79;
    final String? authToken = authProvider.authToken;

    if (authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Sessione scaduta. Riloggare.')),
      );
      return;
    }

    try {
      // 1. Chiama il processo SOS nel provider
      await emergencyProvider.sendSos(
        latitude: simulatedLat,
        longitude: simulatedLng,
        authToken: authToken,
      );

      // 2. Successo
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ SOS INVIATO! Notifiche attivate."),
            backgroundColor: Colors.green,
          ),
        );
        // Torna alla schermata principale/home dopo aver inviato l'SOS
        Navigator.of(context).pop();
      }
    } catch (e) {
      // 3. Gestione errori
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invio SOS fallito: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final isSending = context.watch<EmergencyProvider>().isSendingSos;

    // Variabili per la responsività
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final bool isWideScreen = screenWidth > 600;

    // Dimensione dei font dinamiche basate sulla larghezza dello schermo
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
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _buildSosImage(), // Helper per l'immagine
                  ),
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
                  isDisabled: isSending,
                  onConfirm: () => _handleConfirmSos(context),
                ),
              ),

              const Spacer(flex: 1),

              // 4. Footer (Testo Legale e Pulsante Annulla)
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
                    onPressed: isSending ? null : () => Navigator.of(context).pop(), // Disabilita se sta inviando
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
