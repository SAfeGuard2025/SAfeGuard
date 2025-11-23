import 'package:data_models/UtenteGenerico.dart';
import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import '../repositories/UserRepository.dart';

const String _RESCUER_DOMAIN = '@soccorritore.gmail';

class RegisterService {
  final UserRepository _userRepository;

  RegisterService(this._userRepository);

  Future<UtenteGenerico> register(Map<String, dynamic> requestData, String password) async {
    final email = requestData['email'] as String?;

    if (email == null || password.isEmpty) {
      throw Exception('Email e Password sono obbligatori.');
    }
    if (await _userRepository.findUserByEmail(email) != null) {
      throw Exception('Utente con questa email è già registrato.');
    }

    // 1. Prepara il payload con la password (in chiaro per la simulazione)
    requestData['passwordHash'] = password;

    // 2. Determina il tipo di Utente e crea l'oggetto con ID 0 temporaneo
    final UtenteGenerico newUser;

    // Aggiungiamo un ID temporaneo (0) perché il costruttore Utente/Soccorritore lo richiede,
    // anche se il repository assegnerà l'ID finale.
    requestData['id'] = 0;

    if (email.toLowerCase().endsWith(_RESCUER_DOMAIN)) {
      newUser = Soccorritore.fromJson(requestData);
    } else {
      newUser = Utente.fromJson(requestData);
    }

    // 3. Salva l'utente nel Database (il Repository assegna l'ID finale e ritorna l'oggetto corretto)
    final savedUser = await _userRepository.saveUser(newUser);

    // 4. Ritorna l'oggetto salvato (che contiene l'ID finale)
    return savedUser;
  }
}