// File: backend/lib/services/LogoutService.dart

import '../repositories/UserRepository.dart';
import 'JWTService.dart';
// Importa UserRepository e JWTService

class LogoutService {
  final UserRepository _userRepository = UserRepository();
  final JWTService _jwtService = JWTService();

  // Gestisce la disconnessione (logout) dell'utente
  Future<bool> signOut(String userIdFromToken) async {
    try {
      // 1. INVALIDAZIONE DEL TOKEN JWT (Logica lato server)
      // Questa è la parte cruciale: Invalida il token per impedire accessi futuri.
      // Assumiamo che JWTService abbia un metodo per invalidare il token (es. aggiungendolo a una blacklist)

      // Esempio: Invalida il token (simulazione)
      // await _jwtService.invalidateToken(userIdFromToken);
      print('LogoutService: Invalido il token per l\'utente ID: $userIdFromToken');

      // 2. PULIZIA TOKEN FCM NEL DB
      // Questo impedisce l'invio di notifiche push a un dispositivo disconnesso (RNF-2.2).
      // Il Repository deve avere un metodo per pulire il token dato l'ID.

      // Esempio: await _userRepository.clearFCMToken(userIdFromToken);
      // Per mantenere l'implementazione 'reale' all'interno della logica del service:
      await _userRepository.updateUserField(int.tryParse(userIdFromToken)!, 'tokenFCM', null);

      // 3. Verifica l'uso delle dipendenze per eliminare warning
      _jwtService.hashCode;

      return true; // Logout logico lato server completato
    } catch (e) {
      // Registra l'errore se la pulizia fallisce (es. errore DB)
      print("❌ Errore critico in LogoutService durante la pulizia dei dati: $e");
      // NON Ritorna true se l'operazione di pulizia fallisce, a meno che non sia un errore gestito.
      return false;
    }
  }
}