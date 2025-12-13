import 'package:dotenv/dotenv.dart';

class RescuerConfig {
  // Inizializza DotEnv includendo le variabili di sistema (come nel main)
  static final _env = DotEnv(includePlatformEnvironment: true)..load();

  static List<String> get domains {
    // Usa _env per cercare sia nel file .env che nelle variabili di sistema
    final String? envString = _env['RESCUER_DOMAINS'];

    // Se la variabile è nulla o vuota, usa il fallback
    if (envString == null || envString.trim().isEmpty) {
      return ['@safeguard.it'];
    }

    // Divide la stringa per virgola e rimuove eventuali spazi bianchi ai lati
    return envString.split(',').map((domain) => domain.trim()).toList();
  }

  // Helper per verificare se un'email è valida
  static bool isSoccorritore(String email) {
    final cleanEmail = email.trim().toLowerCase();
    return domains.any((domain) {
      return cleanEmail.endsWith(domain) && cleanEmail.length > domain.length;
    });
  }
}
