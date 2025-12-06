    import 'package:flutter/material.dart';
    import 'package:frontend/providers/notification_provider.dart';
    import 'package:provider/provider.dart';
    import 'package:firebase_core/firebase_core.dart';

    import 'package:frontend/providers/auth_provider.dart';
    import 'package:frontend/providers/medical_provider.dart';
    import 'package:frontend/providers/emergency_provider.dart';
    import 'package:frontend/providers/permission_provider.dart';
    import 'package:frontend/ui/screens/auth/loading_screen.dart';
    import 'package:frontend/providers/report_provider.dart';
    import 'package:firebase_messaging/firebase_messaging.dart';

    @pragma('vm:entry-point')
    Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
      // Rinizializza Firebase, necessario se l'app è stata terminata e viene riattivata in background

    }

    // Funzione Main: Punto di partenza dell'Applicazione
    void main() async {
      WidgetsFlutterBinding.ensureInitialized();

      // Inizializza Firebase
      await Firebase.initializeApp();

      runApp(
        // Utilizza MultiProvider per iniettare più Provider nell'albero dei widget
        MultiProvider(
          providers: [
            // Lista dei Change Notifier Provider resi disponibili a tutta l'app
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => MedicalProvider()),
            ChangeNotifierProvider(create: (_) => EmergencyProvider()),
            ChangeNotifierProvider(create: (_) => PermissionProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ChangeNotifierProvider(create: (_) => ReportProvider()),
          ],
          // Il widget radice dell'applicazione
          child: const SAfeGuard(),
        ),
      );
    }

    // Widget Radice dell'Applicazione
    class SAfeGuard extends StatelessWidget {
      const SAfeGuard({super.key});

      @override
      Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeGuard',
      // Rimuove il banner di debug
      debugShowCheckedModeBanner: false,
      // La schermata iniziale che gestirà il reindirizzamento (login/home)
      home: const LoadingScreen(),
    );
  }
}
