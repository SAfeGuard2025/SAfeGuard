import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Importa il pacchetto dotenv

// Importa il servizio che gestisce le chiamate HTTP
import 'services/user_api_service.dart';

// Importa il modello di dati comune
import 'package:data_models/user.dart';

// 2. Trasforma il main in asincrono per caricare il file .env
Future<void> main() async {
  // 3. Assicura che il binding con il motore nativo sia attivo (necessario prima di codice asincrono nel main)
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Carica le variabili d'ambiente dal file asset
  // Nota: Assicurati che il file .env esista e sia dichiarato nel pubspec.yaml
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Rimuove il banner di debug (opzionale)
      home: const UserScreen(),
    );
  }
}

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  UserScreenState createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
  final UserApiService _apiService = UserApiService();
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    // La chiamata partirà usando l'URL configurato dinamicamente nel Service tramite .env
    _userFuture = _apiService.fetchUser(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Flutter (Front-end)')),
      body: Center(
        child: FutureBuilder<User>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Errore di connessione: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            } else if (snapshot.hasData) {
              final user = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Dati Ricevuti dal Back-end:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('ID: ${user.id}'),
                  Text('Nome: ${user.name}'),
                  Text('Email: ${user.email}'),
                ],
              );
            }
            return const Text('In attesa di dati...');
          },
        ),
      ),
    );
  }
}
