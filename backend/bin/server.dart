import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:dotenv/dotenv.dart';

// Importa il modello di dati comune (p. es. la classe User)
import 'package:data_models/user.dart';

// Importa il middleware per la gestione CORS
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

// Funzione di gestione (handler) per le richieste HTTP
Response _userHandler(Request request) {
  // Esegue il routing solo per l'URL specifico atteso: /api/v1/user/1
  if (request.url.pathSegments.join('/') == 'api/v1/user/1') {
    // 1. LOGICA DI BACK-END: Recupera i dati dell'utente (simulato da un DB)
    final userFromDatabase = User(
      id: 1,
      name: 'Giovanni',
      email: 'giovanni@unisa.it',
    );

    // 2. SERIALIZZAZIONE: Converte l'oggetto Dart (User) in una stringa JSON
    // Si usa il metodo .toJson() del modello seguito da json.encode()
    final jsonBody = json.encode(userFromDatabase.toJson());

    // 3. RISPOSTA HTTP: Invia il JSON con l'header 'Content-Type' corretto
    return Response.ok(jsonBody, headers: {'Content-Type': 'application/json'});
  }

  // Risposta di errore per endpoint non corrispondenti
  return Response.notFound('Endpoint non trovato');
}

void main() async {
  // Mappa di configurazione predefinita per il middleware CORS
  // Permette l'accesso da tutte le origini ('*') per i test
  final defaultHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Content-Type': 'application/json',
  };

  // Crea una Pipeline per incanalare i middleware e l'handler
  final handler = const Pipeline()
      .addMiddleware(
        logRequests(),
      ) // Middleware per loggare le richieste sulla console
      .addMiddleware(
        corsHeaders(headers: defaultHeaders),
      ) // Applica il middleware CORS con gli header predefiniti
      .addHandler(
        _userHandler,
      ); // Aggiunge l'handler finale che gestisce la logica di business

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  // Avvia il server HTTP sulla porta e interfaccia specificate
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print(
    'Server Back-end in ascolto su http://${server.address.host}:${server.port}',
  );

  // Inizializza l'istanza
  final dotEnv = DotEnv();

  if (File('.env').existsSync()) {
    dotEnv.load(); // Carica solo se il file c'è
    print('Configurazione caricata da .env');
  } else {
    print('File .env non trovato, skip caricamento.');
  }

  // Cerca la variabile prima nel .env, se non c'è (o .env non caricato) cerca nel sistema
  final dbUrl = dotEnv['DATABASE_URL'] ?? Platform.environment['DATABASE_URL'];

  print('DB URL: $dbUrl');
}
