import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart';
import 'package:firedart/firedart.dart';

import 'package:backend/controllers/LoginController.dart';
import 'package:backend/controllers/RegisterController.dart';
import 'package:backend/controllers/VerificationController.dart';
import 'package:backend/controllers/ProfileController.dart';
import 'package:backend/controllers/AuthGuard.dart';


void main() async {
  // 1. Configurazione ambiente
  // Carica le variabili dal file .env e determina la porta del server
  var env = DotEnv(includePlatformEnvironment: true)..load();
  final portStr = Platform.environment['PORT'] ?? env['PORT'] ?? '8080';
  final int port = int.parse(portStr);

  // Recupera l'ID del database e ferma l'app in assenza
  final projectId = Platform.environment['FIREBASE_PROJECT_ID'] ?? env['FIREBASE_PROJECT_ID'];

  if (projectId == null) {
    print('❌ ERRORE CRITICO: Variabile FIREBASE_PROJECT_ID mancante.');
    exit(1);
  }

  // 2. DataBase
  // Inizializzazione client Firestore
  Firestore.initialize(projectId);
  print('🔥 Firestore inizializzato: $projectId');

  // 3. Controllers
  // Istanzia le classi che contengono la logica di business
  final loginController = LoginController();
  final registerController = RegisterController();
  final verifyController = VerificationController();
  final profileController = ProfileController();
  final authGuard = AuthGuard();

  // 4. Rounting pubblico
  // Router principale per endpoint accessibili a tutti
  final app = Router();

  app.post('/api/auth/login', loginController.handleLoginRequest);
  app.post('/api/auth/google', loginController.handleGoogleLoginRequest);
  app.post('/api/auth/apple', loginController.handleAppleLoginRequest);
  app.post('/api/auth/register', registerController.handleRegisterRequest);
  app.post('/api/verify', verifyController.handleVerificationRequest);
  app.get('/health', (Request request) => Response.ok('OK'));

  // 5. Routing Protetto
  // Sotto-router dedicato alle operazioni sull'utente loggato
  final profileApi = Router();

  // Lettura dati
  profileApi.get('/', profileController.getProfile); // Nota: il path base è già /api/profile

  // Modifica dati
  profileApi.put('/anagrafica', profileController.updateAnagrafica);
  profileApi.put('/permessi', profileController.updatePermessi);
  profileApi.put('/condizioni', profileController.updateCondizioni);
  profileApi.put('/notifiche', profileController.updateNotifiche);
  profileApi.put('/password', profileController.updatePassword);

  // Aggiunta elementi a liste
  profileApi.post('/allergie', profileController.addAllergia);
  profileApi.post('/medicinali', profileController.addMedicinale);
  profileApi.post('/contatti', profileController.addContatto);

  // Rimozione elementi o cancellazione account
  profileApi.delete('/allergie', profileController.removeAllergia);
  profileApi.delete('/medicinali', profileController.removeMedicinale);
  profileApi.delete('/contatti', profileController.removeContatto);
  profileApi.delete('/', profileController.deleteAccount); // DELETE sull'utente stesso

  // 6. Mounting & Middleware
  // Collega il router profilo a '/api/profile'
  // Passa attraverso il controller AuthGuard per controllare il token di sessione
  app.mount('/api/profile', Pipeline()
      .addMiddleware(authGuard.middleware)
      .addHandler(profileApi)
  );

  // 7. Pipeline Server
  // Aggiunge il logging delle richieste a tutte le chiamate
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(app);

  // 8. Avvio Server
  // Mette in ascolto il server sull'indirizzo IPv4 e porta configurata
  final server = await io.serve(
      handler,
      InternetAddress.anyIPv4,
      port
  );

  print(' Server in ascolto su http://${server.address.host}:${server.port}');
}