import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart';
import 'package:firedart/firedart.dart';

// Assicurati che i path dei package siano corretti nel tuo progetto
import 'package:backend/controllers/LoginController.dart';
import 'package:backend/controllers/RegisterController.dart';
import 'package:backend/controllers/VerificationController.dart';
import 'package:backend/controllers/ProfileController.dart'; // Importa il nuovo controller
import 'package:backend/controllers/AuthGuard.dart'; // Importa il Middleware


void main() async {
  // 1. Caricamento Variabili d'ambiente
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // 2. Configurazione Porta e Progetto Firebase
  final portStr = Platform.environment['PORT'] ?? env['PORT'] ?? '8080';
  final int port = int.parse(portStr);

  final projectId = Platform.environment['FIREBASE_PROJECT_ID'] ?? env['FIREBASE_PROJECT_ID'];

  if (projectId == null) {
    print('❌ ERRORE CRITICO: Variabile FIREBASE_PROJECT_ID mancante.');
    exit(1);
  }

  // 3. Inizializzazione Database
  Firestore.initialize(projectId);
  print('🔥 Firestore inizializzato: $projectId');

  // Inizializzazione Controller e Middleware
  final loginController = LoginController();
  final registerController = RegisterController();
  final verifyController = VerificationController();
  final profileController = ProfileController(); // Istanzia il controller del profilo
  final authGuard = AuthGuard();
  // 4. Router Principale
  final app = Router();

  // --- ROTTE PUBBLICHE (AUTH) ---
  app.post('/api/auth/login', loginController.handleLoginRequest);
  app.post('/api/auth/google', loginController.handleGoogleLoginRequest);
  app.post('/api/auth/apple', loginController.handleAppleLoginRequest);
  app.post('/api/auth/register', registerController.handleRegisterRequest);
  app.post('/api/verify', verifyController.handleVerificationRequest);
  app.get('/health', (Request request) => Response.ok('OK'));

  // --- ROTTE PROTETTE (PROFILO UTENTE) ---
  final profileApi = Router();

  // GET
  profileApi.get('/', profileController.getProfile); // Nota: il path base è già /api/profile

  // PUT
  profileApi.put('/anagrafica', profileController.updateAnagrafica);
  profileApi.put('/permessi', profileController.updatePermessi);
  profileApi.put('/condizioni', profileController.updateCondizioni);
  profileApi.put('/notifiche', profileController.updateNotifiche);
  profileApi.put('/password', profileController.updatePassword);

  // POST (per aggiungere elementi a liste)
  profileApi.post('/allergie', profileController.addAllergia);
  profileApi.post('/medicinali', profileController.addMedicinale);
  profileApi.post('/contatti', profileController.addContatto);

  // DELETE (per rimuovere elementi da liste o eliminare l'account)
  profileApi.delete('/allergie', profileController.removeAllergia);
  profileApi.delete('/medicinali', profileController.removeMedicinale);
  profileApi.delete('/contatti', profileController.removeContatto);
  profileApi.delete('/', profileController.deleteAccount); // DELETE sull'utente stesso

  // Montiamo il router del profilo sotto /api/profile/
  // Tutte le rotte definite in 'profileApi' saranno protette da AuthGuard.
  app.mount('/api/profile', Pipeline()
      .addMiddleware(authGuard.middleware)
      .addHandler(profileApi)
  );

  // 5. Configurazione Pipeline Principale (Logging + Routing)
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(app);

  // 6. Avvio Server
  final server = await io.serve(
      handler,
      InternetAddress.anyIPv4,
      port
  );

  print(' Server in ascolto su http://${server.address.host}:${server.port}');
}