// File: lib/services/JWTService.dart

import 'dart:convert';

// CHIAVE SEGRETA: Questa DEVE essere una stringa lunga e casuale,
// conservata in modo sicuro (es. variabili d'ambiente).
const String jwtSecret = "la_mia_chiave_segreta_molto_forte_e_lunga";

class JWTService {
  // Simula la generazione di un token JWT
  String generateToken(int userId, String userType) {
    // 1. Definisce il Payload (Claims)
    final payload = {
      'id': userId, // Identificatore univoco
      'type':
          userType, // Utile per le logiche di autorizzazione (Utente/Soccorritore)
      'iat': DateTime.now().millisecondsSinceEpoch, // Issued At
      'exp': DateTime.now()
          .add(const Duration(days: 7))
          .millisecondsSinceEpoch, // Scadenza (es. 7 giorni)
    };

    // 2. Simula la creazione del token firmato
    // In un'implementazione reale: JWT.sign(payload, _JWT_SECRET, algorithm: HS256)

    // Per la simulazione, creiamo una stringa base64 fittizia
    final header = '{"alg": "HS256", "typ": "JWT"}';
    final payloadEncoded = Uri.encodeComponent(payload.toString());
    final signature = 'FAKE_SIGNATURE';

    return '${base64Url.encode(utf8.encode(header))}.$payloadEncoded.$signature';
  }

  // Simula la verifica e decodifica di un token JWT
  Map<String, dynamic>? verifyToken(String token) {
    // In un'implementazione reale: verifica la firma, la scadenza e decodifica il payload.
    // ... logica di verifica ...

    // Se la verifica fallisce: return null;

    // Per la simulazione, assumiamo che sia sempre valido e restituiamo un payload parziale
    final parts = token.split('.');
    if (parts.length != 3) return null;

    // Logica di decodifica incompleta per la simulazione
    return {'id': 101, 'type': 'Utente'};
  }
}
