import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:backend/services/login_service.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/jwt_service.dart';

// Import per la generazione dei Mock
@GenerateNiceMocks([MockSpec<UserRepository>(), MockSpec<JWTService>()])
import 'login_service_test.mocks.dart';

void main() {
  late LoginService loginService;
  late MockUserRepository mockUserRepository;
  late MockJWTService mockJWTService;

  // Funzione helper per simulare l'hash della password
  String mockHashPassword(String password) {
    const secret = 'fallback_secret_dev';
    final bytes = utf8.encode(password + secret);
    return sha256.convert(bytes).toString();
  }

  // Setup Iniziale del Test
  setUp(() {
    mockUserRepository = MockUserRepository();
    mockJWTService = MockJWTService();

    // Iniezione delle dipendenze
    loginService = LoginService(
      userRepository: mockUserRepository,
      jwtService: mockJWTService,
    );
  });

  group('LoginService - Metodo login', () {
    // Scenario 1: login con email e password corretta
    test(
      'Deve restituire user e token quando le credenziali sono corrette',
      () async {
        // 1. arrange
        const email = 'test@example.com';
        const password = 'passwordCorretta123';
        final passwordHash = mockHashPassword(password);

        // Dati utente simulati dal DB
        final mockUserData = {
          'id': 6,
          'email': email,
          'nome': 'Mario',
          'cognome': 'Rossi',
          'passwordHash': passwordHash,
          'attivo': true, // Utente verificato
          'isVerified': true,
          'ruolo': 'utente',
        };

        // Stubbing: Quando si cerca l'email, restituisce l'utente trovato
        when(
          mockUserRepository.findUserByEmail(email),
        ).thenAnswer((_) async => mockUserData);

        // Stubbing: Generazione token
        when(
          mockJWTService.generateToken(any, any),
        ).thenReturn('mock_token_jwt');

        // act
        final result = await loginService.login(
          email: email,
          password: password,
        );

        // assert
        expect(result, isNotNull);
        expect(result!['token'], 'mock_token_jwt');
        expect(result['user'].email, email); // Verifica deserializzazione

        // verifica interazione col Mock
        verify(mockUserRepository.findUserByEmail(email)).called(1);
        verify(mockJWTService.generateToken(6, 'Utente')).called(1);
      },
    );

    // Scenario 2: Password Errata
    test('Deve restituire null se la password è errata', () async {
      // arrange
      const email = 'mariorossi@safeguard.it';
      final storedHash = mockHashPassword('password_giusta');

      final mockUserData = {
        'id': 3,
        'email': email,
        'passwordHash': storedHash,
        'attivo': true,
      };

      when(
        mockUserRepository.findUserByEmail(email),
      ).thenAnswer((_) async => mockUserData);

      // act
      final result = await loginService.login(
        email: email,
        password: 'password_sbagliata',
      );

      // assert
      expect(
        result,
        isNull,
      ); // Il service restituisce null se l'hash non matcha
      verifyNever(
        mockJWTService.generateToken(any, any),
      ); // Token non deve essere generato
    });

    // Scenario 3: Utente non verificato
    test(
      'Deve lanciare eccezione USER_NOT_VERIFIED se utente non attivo',
      () async {
        // arrange
        const email = 'utenteInattivo@safeguard.it';
        const password = 'passwordCorretta123';
        final passwordHash = mockHashPassword(password);

        final mockUserData = {
          'id': 2,
          'email': email,
          'passwordHash': passwordHash,
          'attivo': false,
          'isVerified': false,
        };

        when(
          mockUserRepository.findUserByEmail(email),
        ).thenAnswer((_) async => mockUserData);

        // act e assert
        // Verifica che venga lanciata l'eccezione specifica
        expect(
          () async =>
              await loginService.login(email: email, password: password),
          throwsA(predicate((e) => e.toString().contains('USER_NOT_VERIFIED'))),
        );
      },
    );

    // Scenario 4: Utente inesistente
    test('Deve restituire null se l\'utente non esiste', () async {
      // arrange
      const email = 'utenteInsesistente@safeguard.it';

      // Repository restituisce null
      when(
        mockUserRepository.findUserByEmail(email),
      ).thenAnswer((_) async => null);

      // Fallback sul telefono
      when(
        mockUserRepository.findUserByPhone(any),
      ).thenAnswer((_) async => null);

      // act
      final result = await loginService.login(
        email: email,
        password: 'passwordCorretta123',
      );

      // assert
      expect(result, isNull);
    });

    // Scenario 5: Input Mancante
    test(
      'Deve lanciare ArgumentError se email e telefono sono nulli',
      () async {
        // act e assert
        expect(
          () async => await loginService.login(password: 'password'),
          throwsArgumentError,
        );
      },
    );

    // Scenario 6: Password Vuota
    test(
      'Deve restituire null se la password fornita è una stringa vuota',
      () async {
        // arrange
        const email = 'luigiVerdi@Safeguard.it';
        // Nel DB c'è una password valida salvata
        final storedHash = mockHashPassword('password_segreta_vera');

        final mockUserData = {
          'id': 1,
          'email': email,
          'passwordHash': storedHash,
          'attivo': true,
          'isVerified': true,
        };

        when(
          mockUserRepository.findUserByEmail(email),
        ).thenAnswer((_) async => mockUserData);

        // act
        // Proviamo a fare login passando una stringa vuota
        final result = await loginService.login(email: email, password: '');

        // assert
        // Ci aspettiamo che il login fallisca (ritorni null) perché
        // l'hash della stringa vuota non corrisponderà mai all'hash della password vera.
        expect(result, isNull);

        // Verifica di sicurezza: Il token non deve essere mai stato generato
        verifyNever(mockJWTService.generateToken(any, any));
      },
    );

    // Scenario 7: Login con Telefono (+39) Corretto
    test(
      'Deve effettuare login con successo usando numero di telefono con prefisso +39',
      () async {
        // arrange
        const telefono = '+393331234567';
        const password = 'passwordTelefono';
        final passwordHash = mockHashPassword(password);

        final mockUserData = {
          'id': 77,
          //L'email serve per sapere il valore di _isSoccorritore
          'email': 'telefono@example.com',
          'telefono': telefono,
          'passwordHash': passwordHash,
          'attivo': true,
          'isVerified': true,
          'ruolo': 'utente',
        };

        // Non trova email, quindi cerca direttamente per telefono
        when(
          mockUserRepository.findUserByPhone(telefono),
        ).thenAnswer((_) async => mockUserData);

        when(
          mockJWTService.generateToken(any, any),
        ).thenReturn('token_telefono_valid');

        // act
        // Si passa telefono e password (email è null di default)
        final result = await loginService.login(
          telefono: telefono,
          password: password,
        );

        // assert
        expect(result, isNotNull);
        expect(result!['token'], 'token_telefono_valid');

        // Verifica che sia stato chiamato il metodo findUserByPhone e non findUserByEmail
        verify(mockUserRepository.findUserByPhone(telefono)).called(1);
        verifyNever(mockUserRepository.findUserByEmail(any));
      },
    );

    // Scenario 8: Login con Telefono errato o non presente nel DB
    test(
      'Deve restituire null se il numero di telefono non esiste o ha formato errato',
      () async {
        // arrange
        // Formato sbagliato o inesistente
        const telefonoErrato = '12345';

        // Il repository restituisce null (non trovato)
        when(
          mockUserRepository.findUserByPhone(telefonoErrato),
        ).thenAnswer((_) async => null);

        // act
        final result = await loginService.login(
          telefono: telefonoErrato,
          password: 'password',
        );

        // assert
        expect(result, isNull);
        verify(mockUserRepository.findUserByPhone(telefonoErrato)).called(1);
      },
    );
  });
}
