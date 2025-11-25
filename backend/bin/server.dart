import 'dart:io'; // Necessario per Platform.environment
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart'; // Assicurati di averlo nel pubspec.yaml
import 'package:firedart/firedart.dart';

// Import dei tuoi controller
import 'package:backend/controllers/LoginController.dart';
import 'package:backend/controllers/RegisterController.dart';
import 'package:backend/controllers/VerificationController.dart';

void main() async {
  // 1. Caricamento Variabili:
  // DotEnv(includePlatformEnvironment: true) fonde le variabili di sistema (es. Docker)
  // con quelle del file .env locale.
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // 2. Recupero Configurazioni Sicure
  // Usiamo 'Platform.environment' come fonte primaria (Produzione),
  // con fallback su 'env' (Sviluppo locale) o valori di default.

  // PORTA: I cloud provider (es. Cloud Run) iniettano la variabile PORT.
  final portStr = Platform.environment['PORT'] ?? env['PORT'] ?? '8080';
  final int port = int.parse(portStr);

  // PROJECT ID: Fondamentale per Firestore
  final projectId = Platform.environment['FIREBASE_PROJECT_ID'] ?? env['FIREBASE_PROJECT_ID'];

  if (projectId == null) {
    print('ERRORE CRITICO: Variabile FIREBASE_PROJECT_ID non trovata.');
    print('Assicurati di averla impostata nel sistema o nel file .env');
    exit(1); // Chiude il server se manca la configurazione
  }

  // 3. Inizializzazione Database
  Firestore.initialize(projectId);
  print('Firestore inizializzato con Project ID: $projectId');

  // Inizializzazione Controller
  final loginController = LoginController();
  final registerController = RegisterController();
  final verifyController = VerificationController();

  // 4. Router
  final app = Router();

  app.post('/api/auth/login', (Request request) async {
    final body = await request.readAsString();
    return Response.ok(await loginController.handleLoginRequest(body));
  });

  app.post('/api/auth/register', (Request request) async {
    final body = await request.readAsString();
    return Response.ok(await registerController.handleRegisterRequest(body));
  });

  app.post('/api/verify', (Request request) async {
    final body = await request.readAsString();
    return Response.ok(await verifyController.handleVerificationRequest(body));
  });

  // Health Check (Utile per i Cloud Provider)
  app.get('/health', (Request request) => Response.ok('OK'));

  // 5. Avvio Server
  // Ascolta su 0.0.0.0 (InternetAddress.anyIPv4) fondamentale per Docker/Cloud
  final server = await io.serve(
      logRequests().addHandler(app),
      InternetAddress.anyIPv4,
      port
  );

  print('Server in ascolto su http://${server.address.host}:${server.port}');
}