import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Import delle classi del backend
import 'package:backend/services/login_service.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/jwt_service.dart';

@GenerateMocks([UserRepository, JWTService])
import 'login_hashing_test.mocks.dart';

void main() {
  group('LoginService Password Hashing Test', () {
    late LoginService loginService;
    late MockUserRepository mockRepo;
    late MockJWTService mockJwt;

    const String secret = 'fallback_secret_dev';
    const String plainPassword = 'PasswordSicura123!';

    // Calcolo hash atteso
    final bytes = utf8.encode(plainPassword + secret);
    final String expectedHash = sha256.convert(bytes).toString();

    final fakeUserData = {
      'id': 1,
      'email': 'test@example.com',
      'passwordHash': expectedHash,
      'isVerified': true,
      'attivo': true,
      'nome': 'Mario',
      'cognome': 'Rossi',
      'isSoccorritore': false,
    };

    setUp(() {
      mockRepo = MockUserRepository();
      mockJwt = MockJWTService();

      when(mockJwt.generateToken(any, any)).thenReturn("fake_token_123");

      loginService = LoginService(
        userRepository: mockRepo,
        jwtService: mockJwt,
      );
    });

    // --- Scenario 1: Login Email Success ---
    test('Login Success: Il service calcola correttamente l\'hash', () async {
      //Restituiamo una COPIA (.from) per evitare che il Service modifichi fakeUserData originale
      when(mockRepo.findUserByEmail('test@example.com'))
          .thenAnswer((_) async => Map<String, dynamic>.from(fakeUserData));

      final result = await loginService.login(
        email: 'test@example.com',
        password: plainPassword,
      );

      expect(result, isNotNull);
      expect(result?['token'], equals('fake_token_123'));
    });

    // --- Scenario 2: Login Telefono Success ---
    test('Login Success: Login tramite Telefono', () async {
      // Creiamo una copia e aggiungiamo il telefono
      final phoneUser = Map<String, dynamic>.from(fakeUserData);
      phoneUser['telefono'] = '+393331234567';

      //Restituiamo una COPIA di phoneUser
      when(mockRepo.findUserByPhone('+393331234567'))
          .thenAnswer((_) async => Map<String, dynamic>.from(phoneUser));

      final result = await loginService.login(
        telefono: '+393331234567',
        password: plainPassword,
      );

      expect(result, isNotNull);
      expect(result?['token'], equals('fake_token_123'));
    });

    // --- Scenario 3: Utente Google/Apple (Fail login classico) ---
    test('Login Fail: Utente Google/Apple prova login classico', () async {
      final googleUser = Map<String, dynamic>.from(fakeUserData);
      googleUser['passwordHash'] = ''; // Hash vuoto

      when(mockRepo.findUserByEmail('test@example.com'))
          .thenAnswer((_) async => Map<String, dynamic>.from(googleUser));

      expect(
            () async => await loginService.login(
          email: 'test@example.com',
          password: 'QualsiasiPassword',
        ),
        throwsA(predicate(
                (e) => e.toString().contains('accedere tramite Google/Apple'))),
      );
    });

    // --- Scenario 4: Password Errata ---
    test('Login Fail: Una password diversa genera un hash diverso', () async {
      //Restituiamo una COPIA fresca, con l'hash originale intatto
      when(mockRepo.findUserByEmail('test@example.com'))
          .thenAnswer((_) async => Map<String, dynamic>.from(fakeUserData));

      final result = await loginService.login(
        email: 'test@example.com',
        password: 'PasswordSbagliata',
      );

      expect(result, isNull);
    });
  });
}