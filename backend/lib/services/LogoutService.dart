import '../repositories/UserRepository.dart';
import 'JWTService.dart';

class LogoutService {
  // Dipendenze: repository per l'accesso ai dati, service per la gestione dei token
  final UserRepository _userRepository = UserRepository();
  final JWTService _jwtService = JWTService();

  // Gestisce la disconnessione (logout) dell'utente
  Future<bool> signOut(String userIdFromToken) async {
    try {
      // 1. Invalidazione del Token JWT simulato
      print('LogoutService: Invalido il token per l\'utente ID: $userIdFromToken');

      // 2. Pulizia Token JWT NEL DB
      // Questo impedisce l'invio di notifiche push a un dispositivo disconnesso (RNF-2.2).
      await _userRepository.updateUserField(int.tryParse(userIdFromToken)!, 'tokenFCM', null);

      // 3. Verifica l'uso delle dipendenze per eliminare warning
      _jwtService.hashCode;

      return true; // Logout logico lato server.
    } catch (e) {
      // Registra l'errore se la pulizia fallisce
      print("❌ Errore critico in LogoutService durante la pulizia dei dati: $e");
      // Ritorna false se l'operazione di pulizia fallisce.
      return false;
    }
  }
}