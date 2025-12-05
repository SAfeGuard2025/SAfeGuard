import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/emergency_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/style/color_palette.dart';


// 🚨 DEFINIZIONE CLASSE WIDGET 🚨
class EmergencyNotification extends StatefulWidget {
  const EmergencyNotification({super.key});

  @override
  State<EmergencyNotification> createState() => _EmergencyNotification();
}

class _EmergencyNotification extends State<EmergencyNotification> {
  @override
  Widget build(BuildContext context) {
    // 1. Controllo Stato Login
    final authProvider = context.watch<AuthProvider>();
    final isLogged = authProvider.isLogged;
    if (!isLogged) {
      return const SizedBox.shrink();
    }

    // 2. 🚨 CONTROLLO ALLERTA & SOS ATTIVO 🚨
    final emergencyProvider = context.watch<EmergencyProvider>();
    final isSendingSos = emergencyProvider.isSendingSos;
    final incomingAlert = emergencyProvider.currentAlert; // Allerta remota

    // Mostra il banner SE: SOS locale ATTIVO O Allerta remota PRESENTE
    if (!isSendingSos && incomingAlert == null) {
      return const SizedBox.shrink();
    }

    // 3. Determinazione del Ruolo e Contenuto
    final isRescuer = authProvider.isRescuer;

    String titolo;
    String sottotitolo;
    Color notificationColor;

    // 🆕 LOGICA CONTENUTO DINAMICO (Precedenza all'allerta remota)
    if (incomingAlert != null) {

      // Contenuto basato sull'allerta push ricevuta
      titolo = incomingAlert.type == 'RESCUER_ALERT'
          ? "🚨 ${incomingAlert.category.toUpperCase()}: INTERVENTO"
          : "⚠️ PERICOLO VICINO A TE";

      sottotitolo = "Coord: ${incomingAlert.lat.toStringAsFixed(3)}, ${incomingAlert.lng.toStringAsFixed(3)}";

      // Colori basati sul tipo di allerta
      notificationColor = incomingAlert.type == 'RESCUER_ALERT'
          ? ColorPalette.electricBlue // Blu per il soccorritore
          : ColorPalette.primaryBrightRed; // Rosso per il pericolo cittadino

    } else {
      // Contenuto basato sull'SOS inviato localmente
      titolo = "SOS Personale Attivo";
      sottotitolo = "Attendere l'intervento, segnalazione inviata.";
      notificationColor = ColorPalette.primaryBrightRed;
    }

    // Icona fissa per coerenza visiva con la pagina degli avvisi.
    const emergencyIcon = Icons.notifications_none;

    // Layout del Banner di Notifica
    return GestureDetector( // 🆕 Rende l'intero banner cliccabile
      onTap: () {
        if (incomingAlert != null) {
          // Passa i dati al Provider per gestire la navigazione/stato
          emergencyProvider.handleNotificationTap(incomingAlert.toJson());
        }
        // Qui potresti aggiungere un else per navigare alla schermata di stato SOS locale
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: notificationColor,
            borderRadius: BorderRadius.circular(24.0), // valore dei mockup
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Icona a sinistra
              const Icon(emergencyIcon, color: Colors.white, size: 36.0),
              const SizedBox(width: 16.0), // spazio tra l'icona e il testo
              // Contenitore del testo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Titolo
                    Text(
                      titolo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Indirizzo
                    Text(
                      sottotitolo, // Ora sottotitolo contiene i dati o lo stato
                      style: const TextStyle(color: Colors.white, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}