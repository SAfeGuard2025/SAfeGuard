import 'package:flutter/material.dart';
import 'package:frontend/providers/notification_provider.dart';
import 'package:provider/provider.dart';

// IMPORT DEI PROVIDER
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/medical_provider.dart';
import 'package:frontend/providers/emergency_provider.dart';
import 'package:frontend/providers/permission_provider.dart'; // <--- ASSICURATI DI QUESTO IMPORT
import 'package:frontend/ui/screens/auth/loading_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicalProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyProvider()),
        ChangeNotifierProvider(create: (_) => PermissionProvider()), // <--- E DI QUESTA RIGA
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