import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Importa il nuovo servizio
import 'package:frontend/services/notification_handler.dart';

import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/medical_provider.dart';
import 'package:frontend/providers/emergency_provider.dart';
import 'package:frontend/providers/permission_provider.dart';
import 'package:frontend/providers/notification_provider.dart';
import 'package:frontend/providers/report_provider.dart';
import 'package:frontend/ui/screens/auth/loading_screen.dart';

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
    // Caso 1: App aperta da stato terminato
    // (FirebaseMessaging.instance è accessibile ovunque ora)
    // Nota: La logica di navigazione specifica può rimanere qui o essere spostata
    // in un NavigationService se l'app cresce.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeGuard',
      debugShowCheckedModeBanner: false,
      home: const LoadingScreen(),
    );
  }
}