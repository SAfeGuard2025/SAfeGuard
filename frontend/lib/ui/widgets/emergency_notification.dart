import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/emergency_provider.dart';
import 'package:provider/provider.dart'; // serve per .watch()

class EmergencyNotification extends StatefulWidget {
  const EmergencyNotification({super.key});

  @override
  State<EmergencyNotification> createState() => _EmergencyNotification();
}

class _EmergencyNotification extends State<EmergencyNotification> {
  @override
  Widget build(BuildContext context) {
    final isLogged = context.watch<AuthProvider>().isLogged;
    
    // se non è loggato non mostro nulla
    if (!isLogged) {
      return Text("");
    }

    // vedo se c'è un'allerta attiva
    final alert = context.watch<EmergencyProvider>().isSendingSos;

    // se non c'è la notifica è chiusa
    if(!alert){
      return const SizedBox.shrink();
    }

    // mi serve per i colori
    final isRescuer = context.watch<AuthProvider>().isRescuer;

    const titolo = "Titolo"; // prende il titolo dell'emergenza (deve essere implementato assieme all'indirizzo in emergency provider)
    const indirizzo = "indirizzo 104"; // prende l'indirizzo dell'emergenza

    // Colori della notifica: blu per il soccorritore e rosso per il cittadino.
    // Ho scelto in modo da creare maggiore contrasto nella homepage in modo che la notifica non possa sfuggire
    Color notificationColor = isRescuer ? Color(0xFF1000ef) : Color(0xFFEF0009);
    // stessa Icon utilizzata per gli avvisi. Messa cosi dò maggiore coerenza e fa capire all'utente a quale pagina andare per approfondire l'evento
    const emergencyIcon = Icons.notifications_none;

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
            const Icon(emergencyIcon, color: Colors.white, size: 36.0),
            SizedBox(width: 16.0), // spazio tra l'icona e il testo
            // Parte del testo (dovrebbe essere responsive)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // testo del titolo
                  Text(
                    titolo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  //testo dell'indirizzo
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
