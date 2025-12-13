import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:data_models/utente.dart';
import 'package:data_models/soccorritore.dart';
import 'package:backend/services/login_service.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/jwt_service.dart';
import 'package:backend/config/rescuer_config.dart'; // Importa la config per i test logici

@GenerateNiceMocks([
  MockSpec<UserRepository>(),
  MockSpec<JWTService>()
])
import 'login_service_test.mocks.dart';

void main() {
  //1: SETUP PER IL TEST DEL SERVICE
  late LoginService loginService;
  late MockUserRepository mockUserRepository;
  late MockJWTService mockJwtService;

  // Helper per l'hash password (simulazione)
  String hashPassword(String password) {
    final secret = 'fallback_secret_dev';
    final bytes = utf8.encode(password + secret);
    return sha256.convert(bytes).toString();
  }

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockJwtService = MockJWTService();

    // Iniezione dei Mock
    loginService = LoginService(
        userRepository: mockUserRepository,
        jwtService: mockJwtService
    );
  });

  //2: TEST LOGICI (RESCUER CONFIG)
  group('TU-05 [Unit] - Logica di Configurazione (RescuerConfig)', () {

    test('CASO 1: Deve identificare come Soccorritore una email con dominio @safeguard.it', () {
      final emailSoccorritore = "mario.rossi@safeguard.it";
      final isSoccorritore = RescuerConfig.isSoccorritore(emailSoccorritore);
      expect(isSoccorritore, isTrue);
    });

    test('CASO 2: NON deve identificare come Soccorritore una email generica (gmail)', () {
      final emailCittadino = "privato@gmail.com";
      final isSoccorritore = RescuerConfig.isSoccorritore(emailCittadino);
      expect(isSoccorritore, isFalse);
    });

    test('CASO 3: Case Insensitive (ignora maiuscole)', () {
      final emailMix = "MARIO@SAFEGUARD.IT";
      final isSoccorritore = RescuerConfig.isSoccorritore(emailMix);
      expect(isSoccorritore, isTrue);
    });

    test('CASO 4: Robustezza (Stringa vuota)', () {
      final isSoccorritore = RescuerConfig.isSoccorritore("");
      expect(isSoccorritore, isFalse);
    });

    test('CASO 5: Sicurezza (Dominio ingannevole es. fakesafeguard.it)', () {
      final isSoccorritore = RescuerConfig.isSoccorritore("hacker@fakesafeguard.it");
      expect(isSoccorritore, isFalse);
    });

    test('CASO 6: Usabilità (Spazi accidentali)', () {
      final isSoccorritore = RescuerConfig.isSoccorritore("  mario.rossi@safeguard.it  ");
      expect(isSoccorritore, isTrue);
    });

    test('CASO 7: Gerarchia (Sottodomini non ammessi)', () {
      final isSoccorritore = RescuerConfig.isSoccorritore("capo@lazio.safeguard.it");
      expect(isSoccorritore, isFalse);
    });

    test('CASO 8: Validità Formale (No username)', () {
      // Questo è il caso che hai FIXATO!
      final isSoccorritore = RescuerConfig.isSoccorritore("@safeguard.it");
      expect(isSoccorritore, isFalse);
    });

    test('CASO 9: Verifica Presenza del Dominio (Mancante)', () {
      final isSoccorritore = RescuerConfig.isSoccorritore("mario.rossi");
      expect(isSoccorritore, isFalse);
    });
  });

  //3: TEST DEL SERVICE
  group('TU-05 [Integration] - LoginService & Role Assignment', () {

    test('Il Service deve restituire un oggetto SOCCORRITORE se la mail è valida', () async {

      final email = "mario.rossi@safeguard.it";
      final password = "Password123!";

      // Setup Mock
      when(mockUserRepository.findUserByEmail(email)).thenAnswer((_) async => {
        'id': 1, 'email': email, 'passwordHash': hashPassword(password),
        'nome': 'Mario', 'isVerified': true, 'attivo': true
      });
      when(mockJwtService.generateToken(any, any)).thenReturn("token");

      final result = await loginService.login(email: email, password: password);

      expect(result!['user'], isA<Soccorritore>(),
          reason: "Il Service non ha istanziato la classe corretta!");
    });

    test('Il Service deve restituire un oggetto UTENTE se la mail è generica', () async {

      final email = "privato@gmail.com";
      final password = "Password123!";

      when(mockUserRepository.findUserByEmail(email)).thenAnswer((_) async => {
        'id': 2, 'email': email, 'passwordHash': hashPassword(password),
        'nome': 'Luigi', 'isVerified': true, 'attivo': true
      });
      when(mockJwtService.generateToken(any, any)).thenReturn("token");

      final result = await loginService.login(email: email, password: password);

      expect(result!['user'], isA<Utente>(),
          reason: "Il Service doveva creare un utente semplice");
    });
  });
}