import 'package:flutter/material.dart';
import 'package:frontend/providers/notification_provider.dart';
import 'package:provider/provider.dart';
// 1. AGGIUNGI QUESTO IMPORT
import 'package:firebase_core/firebase_core.dart';

// IMPORT DEI PROVIDER
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/medical_provider.dart';
import 'package:frontend/providers/emergency_provider.dart';
import 'package:frontend/providers/permission_provider.dart';
import 'package:frontend/ui/screens/auth/loading_screen.dart';

// 2. AGGIUNGI 'async' QUI
void main() async {
  // 3. AGGIUNGI QUESTA RIGA (Obbligatoria per usare plugin prima di runApp)
  WidgetsFlutterBinding.ensureInitialized();

  // 4. INIZIALIZZA FIREBASE
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicalProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyProvider()),
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const SAfeGuard(),
    ),
  );
}

class SAfeGuard extends StatelessWidget {
  const SAfeGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeGuard',
      debugShowCheckedModeBanner: false,
      // ... il resto del tuo tema ...
      home: const LoadingScreen(),
    );
  }
}