import 'package:flutter/material.dart';

// Importa il servizio che gestisce le chiamate HTTP
import 'services/user_api_service.dart';

// Importa il modello di dati comune (p. es. la classe User)
import 'package:data_models/user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inizializza l'applicazione con la schermata principale
    return MaterialApp(home: UserScreen());
  }
}

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  UserScreenState createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
  // Istanza del servizio per la chiamata API
  final UserApiService _apiService = UserApiService();
  // Future che conterrà il risultato della chiamata (un oggetto User)
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    // 1. INIZIO CHIAMATA: Avvia la richiesta dati al Back-end non appena la schermata si carica
    _userFuture = _apiService.fetchUser(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('App Flutter (Front-end)')),
      body: Center(
        // FutureBuilder gestisce e aggiorna l'UI in base allo stato del Future (waiting, error, done)
        child: FutureBuilder<User>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Se lo stato della connessione è in attesa (fetching)
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // Se si è verificato un errore durante la chiamata
              return Text(
                'Errore di connessione: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              );
            } else if (snapshot.hasData) {
              // 2. RICEZIONE DATI: Se i dati sono disponibili
              // I dati JSON sono stati decodificati in un oggetto User nativo di Dart
              final user = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Dati Ricevuti dal Back-end:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('ID: ${user.id}'),
                  Text('Nome: ${user.name}'),
                  Text('Email: ${user.email}'),
                ],
              );
            }
            // Stato di fallback (raro in questo contesto, ma utile)
            return Text('In attesa di dati...');
          },
        ),
      ),
    );
  }
}
