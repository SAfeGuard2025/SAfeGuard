import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

// Import delle classi del backend
import 'package:backend/services/login_service.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/jwt_service.dart';

// mock manuali per semplicità
class MockUserRepository extends Mock implements UserRepository {
  final Map<String, dynamic>? _fakeUser;
  MockUserRepository(this._fakeUser);

  @override
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    if (_fakeUser != null && _fakeUser['email'] == email) {
      return Map<String, dynamic>.from(_fakeUser);
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> findUserByPhone(String phone) async {
    if (_fakeUser != null && _fakeUser['telefono'] == phone) {
      return Map<String, dynamic>.from(_fakeUser);
    }
    return null;
  }
}

class MockJWTService extends Mock implements JWTService {
  @override
  String generateToken(int userId, String userType) => "fake_token_123";
}

void main() {
  group('LoginService Password Hashing Test', () {
    late LoginService loginService;
    late MockUserRepository mockRepo;

    // Configurazione segreta (deve coincidere con il fallback nel service se non viene settato .env)
    const String secret = 'fallback_secret_dev';
    const String plainPassword = 'PasswordSicura123!';

    // 1. Replichiamo la logica di Hashing che ci aspettiamo sia "nascosta" nel service
    // Questo simula ciò che il RegisterService avrebbe salvato nel DB.
    final bytes = utf8.encode(plainPassword + secret);
    final String expectedHash = sha256.convert(bytes).toString();

    // Dati utente simulati nel DB
    final fakeUserData = {
      'id': 1,
      'email': 'test@example.com',
      'passwordHash': expectedHash, // hash calcolato
      'isVerified': true,
      'attivo': true,
      'nome': 'Mario',
      'cognome': 'Rossi',
      'isSoccorritore': false,
    };

    setUp(() {
      mockRepo = MockUserRepository(fakeUserData);
      loginService = LoginService(
        userRepository: mockRepo,
        jwtService: MockJWTService(),
      );
    });

    //scenario 1: login email con successo
    test(
      'Login Success: Il service calcola correttamente l\'hash e trova corrispondenza',
      () async {
        // Act
        final result = await loginService.login(
          email: 'test@example.com',
          password: plainPassword, // Passiamo la password in chiaro
        );

        // Assert
        expect(result, isNotNull, reason: "Il login dovrebbe riuscire");
        expect(result?['token'], equals('fake_token_123'));

        // Se questo test passa, significa che:
        // loginService._hashPassword('PasswordSicura123!') == expectedHash
      },
    );

    //scenario 2: login con cellulare con successo
    test('Login Success: Login tramite Telefono', () async {
      // 1. Arrange: Aggiungiamo un numero di telefono all'utente mock
      final phoneUser = Map<String, dynamic>.from(fakeUserData);
      phoneUser['telefono'] = '+393331234567';

      mockRepo = MockUserRepository(phoneUser);
      loginService = LoginService(
        userRepository: mockRepo,
        jwtService: MockJWTService(),
      );

      // 2. Act: Proviamo il login usando il parametro 'telefono' invece di 'email'
      final result = await loginService.login(
        telefono: '+393331234567',
        password: plainPassword,
      );

      // 3. Assert
      expect(result, isNotNull);
      expect(result?['token'], equals('fake_token_123'));
    });

    //scenario 3: utente registrato con Google/Apple e tenta login classico ma fallisce
    test(
      'Login Fail: Utente Google/Apple (senza password) prova login classico',
      () async {
        // 1. Creiamo un utente con hash vuoto
        final googleUser = Map<String, dynamic>.from(fakeUserData);
        googleUser['passwordHash'] = ''; // Simuliamo un utente social

        // Aggiorniamo il mock per restituire questo utente
        mockRepo = MockUserRepository(googleUser);
        loginService = LoginService(
          userRepository: mockRepo,
          jwtService: MockJWTService(),
        );

        // 2. Act & Assert: Ci aspettiamo un'eccezione specifica
        expect(
          () async => await loginService.login(
            email: 'test@example.com',
            password:
                'QualsiasiPassword', // Anche se metto una password, deve fallire
          ),
          throwsA(
            predicate(
              (e) => e.toString().contains('accedere tramite Google/Apple'),
            ),
          ),
          reason:
              "Il sistema deve bloccare il login classico se l'utente non ha una password impostata",
        );
      },
    );

    //scenario 4: password errata
    test('Login Fail: Una password diversa genera un hash diverso', () async {
      // Act
      final result = await loginService.login(
        email: 'test@example.com',
        password: 'PasswordSbagliata',
      );

      // Assert
      expect(
        result,
        isNull,
        reason: "Il login deve fallire con password errata",
      );
    });
  });
}
