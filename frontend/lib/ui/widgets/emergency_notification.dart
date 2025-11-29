import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/emergency_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Widget di Notifica di Emergenza
// Mostra un banner colorato quando un'emergenza è attiva.
class EmergencyNotification extends StatefulWidget {
  const EmergencyNotification({super.key});

  @override
  State<EmergencyNotification> createState() => _EmergencyNotification();
}

class _EmergencyNotification extends State<EmergencyNotification> {
  @override
  Widget build(BuildContext context) {
    // 1. Controllo Stato Login
    // Utilizza watch per reagire al cambio di stato di login.
    final isLogged = context.watch<AuthProvider>().isLogged;

    // Se non è loggato non mostro nulla
    if (!isLogged) {
      return const SizedBox.shrink();
    }

    // 2. Controllo Allerta Attiva
    // Controlla se è in corso l'invio di un SOS.
    final alert = context.watch<EmergencyProvider>().isSendingSos;

    // Se non c'è l'allerta, la notifica deve rimanere chiusa.
    if (!alert) {
      return const SizedBox.shrink();
    }

    // 3. Determinazione del Ruolo e Colori
    final isRescuer = context.watch<AuthProvider>().isRescuer;

    // Testo temporaneo (da implementare tramite EmergencyProvider)
    const titolo = "Titolo";
    const indirizzo = "indirizzo 104";

    // Colori dinamici basati sul ruolo per il massimo contrasto:
    // Blu elettrico per il Soccorritore, Rosso vivo per il Cittadino (pericolo).
    Color notificationColor = isRescuer
        ? ColorPalette.electricBlue
        : ColorPalette.primaryBrightRed;

    // Icona fissa per coerenza visiva con la pagina degli avvisi.
    const emergencyIcon = Icons.notifications_none;

    // Layout del Banner di Notifica
    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(
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
            SizedBox(width: 16.0), // spazio tra l'icona e il testo
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
                    indirizzo,
                    style: const TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
