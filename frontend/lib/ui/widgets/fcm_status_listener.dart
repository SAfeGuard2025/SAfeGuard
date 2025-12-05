import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Importa i Provider necessari
import '../../providers/emergency_provider.dart';
import '../../providers/auth_provider.dart';

// Questo widget intercetta i messaggi in foreground e li inoltra all'EmergencyProvider
class FcmStatusListener extends StatefulWidget {
  final Widget child;

  const FcmStatusListener({required this.child, super.key});

  @override
  State<FcmStatusListener> createState() => _FcmStatusListenerState();
}

class _FcmStatusListenerState extends State<FcmStatusListener> {

  @override
  void initState() {
    super.initState();

    // Inizializza i listener al primo frame del widget
    _configureFCMListeners(context);
  }

  // Metodo per gestire il messaggio iniziale (se l'app era chiusa)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chiamato solo una volta per gestire la notifica che ha aperto l'app
    _checkForInitialMessage(context);
  }

  void _configureFCMListeners(BuildContext context) {
    // Usiamo listen: false perché stiamo solo chiamando metodi, non ricostruendo l'UI qui
    final emergencyProvider = Provider.of<EmergencyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 1. 🔔 Messaggio in Foreground (App Aperta)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data;
      final type = data['type'];

      // Solo processa se l'utente è loggato
      if (authProvider.isLogged && (type == 'RESCUER_ALERT' || type == 'DANGER_ALERT')) {

        // Inoltra l'allerta al Provider per aggiornare lo stato e l'UI
        emergencyProvider.handleNewAlert(data);

        // Se è un soccorritore, mostra subito un dialogo urgente
        if (authProvider.isRescuer && type == 'RESCUER_ALERT') {
          _showUrgentRescuerDialog(context, data);
        }
      }
    });

    // 2. 👆 Tocco sulla Notifica (Background State)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final data = message.data;
      // Invia il messaggio al Provider di Emergenza per gestire la navigazione
      emergencyProvider.handleNotificationTap(data);
    });
  }

  // 3. 🏁 Messaggio Iniziale (Terminated State)
  Future<void> _checkForInitialMessage(BuildContext context) async {
    // Controlla se l'app è stata aperta da una notifica mentre era chiusa
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      final data = initialMessage.data;
      // Invia il messaggio al Provider di Emergenza per gestire la navigazione
      Provider.of<EmergencyProvider>(context, listen: false).handleNotificationTap(data);
    }
  }

  // Esempio di dialogo urgente per i soccorritori (in foreground)
  void _showUrgentRescuerDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🚨 RICHIESTA INTERVENTO URGENTE"),
        content: Text("Tipo: ${data['category']}.\nCoordinate: ${data['lat']}, ${data['lng']}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("CHIUDI"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // ➡️ Qui devi chiamare il metodo del Provider che gestisce la navigazione alla mappa
              Provider.of<EmergencyProvider>(context, listen: false).handleNotificationTap(data);
            },
            child: const Text("VISUALIZZA MAPPA"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ritorna il widget figlio (LoadingScreen)
    return widget.child;
  }
}