import 'dart:convert'; // Import aggiunto
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importa il nuovo servizio
import 'package:frontend/services/notification_handler.dart';

import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/medical_provider.dart';
import 'package:frontend/providers/emergency_provider.dart';
import 'package:frontend/providers/permission_provider.dart';
import 'package:frontend/providers/notification_provider.dart';
import 'package:frontend/providers/report_provider.dart';
import 'package:frontend/providers/risk_provider.dart';
import 'package:frontend/ui/screens/auth/loading_screen.dart';
import 'package:frontend/ui/screens/home/safe_check_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inizializza Firebase
  await Firebase.initializeApp();

  // 2. Inizializza il sistema di notifiche centralizzato
  // Tutta la logica sporca è ora nascosta qui dentro
  await NotificationHandler().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicalProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyProvider()),
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => RiskProvider()),
      ],
      child: const SAfeGuard(),
    ),
  );
}

class SAfeGuard extends StatefulWidget {
  const SAfeGuard({super.key});

  @override
  State<SAfeGuard> createState() => _SAfeGuardState();
}

class _SAfeGuardState extends State<SAfeGuard> {
  @override
  void initState() {
    super.initState();
    // Gestione click su notifica quando app era chiusa/background
    _setupInteractedMessage();
  }

  Future<void> _setupInteractedMessage() async {
    // 1. App aperta da stato TERMINATO
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // 2. App aperta da stato BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) async {
    // Controlla se la notifica è di tipo "emergency_alert" o "safe_check"
    if (message.data['type'] == 'emergency_alert' || message.data['type'] == 'safe_check') {

      // --- CONTROLLO RUOLO UTENTE ---
      final prefs = await SharedPreferences.getInstance();
      final String? userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        try {
          final Map<String, dynamic> userMap = jsonDecode(userDataString);
          if (userMap['isSoccorritore'] == true) {
            debugPrint("⛔ Soccorritore ha cliccato notifica: Blocco apertura SafeCheckScreen.");
            return; //Non navigare se è un soccorritore
          }
        } catch (e) {
          debugPrint("Errore parsing utente in main: $e");
        }
      }
      // -----------------------------

      // Estrai i dati dal payload della notifica (se presenti)
      final String title = message.notification?.title ?? "ALLERTA DI SICUREZZA";

      // Usa la navigatorKey per spingere la schermata
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => SafeCheckScreen(
            title: title,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeGuard',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: const LoadingScreen(),
    );
  }
}