import 'dart:convert';
import 'dart:io';

class JWTService {
  // Recupera la chiave dalle variabili d'ambiente
  String get _secret =>
      Platform.environment['JWT_SECRET'] ??
      'FALLBACK_DEV_SECRET_DO_NOT_USE_IN_PROD';

  // Genera un token JWT (Header.Payload.Signature)
  String generateToken(int userId, String userType) {
    final payload = {
      'id': userId,
      'type': userType,
      'iat': DateTime.now().millisecondsSinceEpoch,
      'exp': DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
    };

    final header = jsonEncode({'alg': 'HS256', 'typ': 'JWT'});
    final headerBase64 = base64Url.encode(utf8.encode(header));
    final payloadBase64 = base64Url.encode(utf8.encode(jsonEncode(payload)));

    final signature = base64Url.encode(utf8.encode('fake_signature_$_secret'));

    // Restituisce il formato JWT completo: Header.Payload.Signature
    return '$headerBase64.$payloadBase64.$signature';
  }

  // Verifica la validità di un token JWT
  Map<String, dynamic>? verifyToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decodifica Payload
      final payloadString = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final payload = jsonDecode(payloadString);

      // Controlla se il token è scaduto
      final exp = payload['exp'] as int?;
      if (exp != null && DateTime.now().millisecondsSinceEpoch > exp) {
        return null;
      }

      return payload;
    } catch (e) {
      return null;
    }
  }
}
