import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:backend/services/register_service.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/verification_service.dart';
import 'package:data_models/utente_generico.dart';

@GenerateNiceMocks([
  MockSpec<UserRepository>(),
  MockSpec<VerificationService>(),
])

import 'register_service_test.mocks.dart';

void main() {
  late RegisterService registerService;
  late MockUserRepository mockUserRepository;
  late MockVerificationService mockVerificationService;

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockVerificationService = MockVerificationService();
    registerService = RegisterService(mockUserRepository, mockVerificationService);
  });

  // Viene usato BaseRequest che ha entrambi i campi
  // Viene usato sovrascrivendo null dove serve o con campi specifici per i test
  final Map<String, dynamic> baseRequest = {
    'nome': 'Mario',
    'cognome': 'Rossi',
    'email': 'mario@test.com',
    'telefono': '3331234567',
  };
  final validPassword = 'Password1!';

  group('RegisterService - Validazioni Input', () {

    // Test Telefono
    // 1. Telefono troppo corto
    test('1. Errore se telefono troppo corto', () async {
      final req = {...baseRequest, 'email': null, 'telefono': '123'};

      await expectLater(
          registerService.register(req, validPassword),
          throwsA(predicate((e) => e.toString().contains('Numero troppo corto')))
      );
    });

    // 2. Telefono troppo lungo
    test('2. Errore se telefono troppo lungo', () async {
      final req = {...baseRequest, 'email': null, 'telefono': '1234567890123456'};

      await expectLater(
          registerService.register(req, validPassword),
          throwsA(predicate((e) => e.toString().contains('Numero troppo lungo')))
      );
    });

    // 3. Telefono vuoto
    test('3. Errore se telefono è vuoto', () async {
      final req = {...baseRequest, 'email': null, 'telefono': ''};

      await expectLater(
          registerService.register(req, validPassword),
          throwsA(predicate((e) => e.toString().contains('Numero non valido')))
      );
    });

    // Validazione Email
    // 4. Formato mail non valida
    test('4. Errore se formato email non valido', () async {
      final req = {...baseRequest, 'telefono': null, 'email': 'email-senza-chiocciola.it'};

      await expectLater(
          registerService.register(req, validPassword),
          throwsA(predicate((e) => e.toString().contains('Formato email non valido')))
      );
    });

    // Validazione Campi Obbligatori
    // 5. Mancanza nome
    test('5. Errore se manca il Nome', () async {
      final req = {...baseRequest, 'nome': null};

      await expectLater(
          registerService.register(req, validPassword),
          throwsA(predicate((e) => e.toString().contains('Nome e Cognome sono obbligatori')))
      );
    });

    // 6. Mancanza cognome
    test('6. Errore se manca il Cognome', () async {
      final req = {...baseRequest, 'cognome': null};

      await expectLater(
          registerService.register(req, validPassword),
          throwsA(predicate((e) => e.toString().contains('Nome e Cognome sono obbligatori')))
      );
    });

    // Validazione Password
    // 7. Password troppo corta
    test('7. Errore se password troppo corta (< 6)', () async {
      final req = {...baseRequest, 'telefono': null};
      await expectLater(
          registerService.register(req, 'Ab1!'),
          throwsA(predicate((e) => e.toString().contains('tra 6 e 12 caratteri')))
      );
    });

    // 8. Password troppo lunga
    test('8. Errore se password troppo Lunga (> 12)', () async {
      final req = {...baseRequest, 'telefono': null};
      await expectLater(
          registerService.register(req, '1234567890A!!'),
          throwsA(predicate((e) => e.toString().contains('tra 6 e 12 caratteri')))
      );
    });

    // 9. Password debole
    test('9. Errore se password debole', () async {
      final req = {...baseRequest, 'telefono': null};
      await expectLater(
          registerService.register(req, 'Password123'),
          throwsA(predicate((e) => e.toString().contains('criteri di sicurezza')))
      );
    });
  });

  group('RegisterService - Logica di Business', () {

    // Duplicati
    // 10. Email già esistente
    test('10. Errore se email già esistente e verificata', () async {
      final req = {...baseRequest, 'telefono': null};

      when(mockUserRepository.findUserByEmail('mario@test.com')).thenAnswer(
              (_) async => {'id': 10, 'email': 'mario@test.com', 'isVerified': true}
      );

      await expectLater(
          registerService.register(req, validPassword),
          throwsA(predicate((e) => e.toString().contains('già registrato')))
      );
    });

    // 11. Telefono già esistente
    test('11. Errore se telefono già esistente e verificato', () async {
      final req = {...baseRequest, 'email': null};

      when(mockUserRepository.findUserByEmail(any)).thenAnswer((_) async => null);
      when(mockUserRepository.findUserByPhone('3331234567')).thenAnswer(
              (_) async => {'id': 11, 'telefono': '3331234567', 'isVerified': true}
      );

      await expectLater(
          registerService.register(req, validPassword),
          throwsA(predicate((e) => e.toString().contains('Utente con questo telefono è già registrato')))
      );
    });

    // Update
    // 12. Aggiornamento utente
    test('12. Deve aggiornare utente esistente se NON è verificato', () async {
      final req = {...baseRequest, 'telefono': null};

      when(mockUserRepository.findUserByEmail('mario@test.com')).thenAnswer(
              (_) async => {'id': 50, 'email': 'mario@test.com', 'isVerified': false}
      );

      when(mockUserRepository.saveUser(any)).thenAnswer(
              (_) async => UtenteGenerico.fromJson({...req, 'id': 50})
      );

      await registerService.register(req, validPassword);

      final verification = verify(mockUserRepository.saveUser(captureAny));
      final savedUser = verification.captured.first as UtenteGenerico;
      expect(savedUser.id, 50, reason: "Doveva mantenere l'ID dell'utente esistente");
    });
  });

  group('RegisterService - Happy Paths (Esclusivi)', () {

    // 13. Registrazione corretta con Email
    test('13. Registrazione solo email (Telefono assente)', () async {
      final Map<String, dynamic> req = {
        'nome': 'Mario',
        'cognome': 'Rossi',
        'email': 'mario@test.com',
        'telefono': null,
      };

      when(mockUserRepository.findUserByEmail(any)).thenAnswer((_) async => null);
      when(mockUserRepository.saveUser(any)).thenAnswer(
              (_) async => UtenteGenerico.fromJson({...req, 'id': 200})
      );

      await registerService.register(req, validPassword);

      // Verifica fondamentale: SMS NON parte
      verifyNever(mockVerificationService.startPhoneVerification(any));
    });

    // 14. Registrazione corretta con telefono
    test('14. Registrazione solo telefono (Email assente)', () async {
      final Map<String, dynamic> req = {
        'nome': 'Mario',
        'cognome': 'Rossi',
        'email': null,
        'telefono': '3331234567',
      };

      when(mockUserRepository.findUserByPhone(any)).thenAnswer((_) async => null);
      when(mockUserRepository.saveUser(any)).thenAnswer(
              (_) async => UtenteGenerico.fromJson({...req, 'id': 300})
      );

      await registerService.register(req, validPassword);

      // Verifica fondamentale: SMS DEVE partire
      verify(mockVerificationService.startPhoneVerification('3331234567')).called(1);
    });
  });
}