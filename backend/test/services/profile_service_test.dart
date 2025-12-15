import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Import dei tuoi file
import 'package:backend/services/profile_service.dart';
import 'package:backend/repositories/user_repository.dart';

// Import del mock generato
@GenerateNiceMocks([MockSpec<UserRepository>()])
import 'profile_service_test.mocks.dart';

void main() {
  late ProfileService profileService;
  late MockUserRepository mockUserRepository;

  const int testUserId = 123;

  // Snapshot dell'utente base prima della modifica
  final Map<String, dynamic> currentUserData = {
    'id': testUserId,
    'email': 'user@example.com',
    'telefono': '3330000000',
    'nome': 'Mario',
    'cognome': 'Rossi',
  };

  setUp(() {
    mockUserRepository = MockUserRepository();
    // Inject dependency: Validatore neutro per i test standard
    // (Simula che nessuna email sia riservata di default, tranne nel TF2)
    profileService = ProfileService(
      userRepository: mockUserRepository,
      validator: (email) => false,
    );
    print('\n--- [SETUP] Test Avviato ---');
  });

  group('ProfileService - updateAnagrafica (Suite Completa 18 Test)', () {
    // =================================================================
    // GRUPPO 1: PRE-CONDIZIONI & SICUREZZA (TF1, TF2)
    // =================================================================

    test('TF1: Deve fallire se l\'utente non esiste', () async {
      when(
        mockUserRepository.findUserById(testUserId),
      ).thenAnswer((_) async => null);

      expect(
        await profileService.updateAnagrafica(testUserId, nome: 'A'),
        false,
      );
    });

    test('TF2: Deve impedire email riservate (Dominio Soccorritore)', () async {
      // Simuliamo config che dica "Sì, è riservata"
      final strictService = ProfileService(
        userRepository: mockUserRepository,
        validator: (email) => true,
      );
      when(
        mockUserRepository.findUserById(testUserId),
      ).thenAnswer((_) async => currentUserData);

      expect(
        await strictService.updateAnagrafica(
          testUserId,
          email: 'admin@safeguard.it',
        ),
        false,
      );
      // Verifica sicurezza: il DB non deve essere toccato
      verifyNever(mockUserRepository.updateUserGeneric(any, any));
    });

    // =================================================================
    // GRUPPO 2: INTEGRITÀ DEI DATI & DUPLICATI (TF3, TF4)
    // =================================================================

    test('TF3: Deve impedire email duplicata (già in uso da altri)', () async {
      when(
        mockUserRepository.findUserById(testUserId),
      ).thenAnswer((_) async => currentUserData);

      // Simula conflitto con altro utente (ID 456)
      when(
        mockUserRepository.findUserByEmail('exist@test.com'),
      ).thenAnswer((_) async => {'id': 456, 'email': 'exist@test.com'});

      expect(
        await profileService.updateAnagrafica(
          testUserId,
          email: 'exist@test.com',
        ),
        false,
      );
    });

    test(
      'TF4: Deve impedire telefono duplicato (già in uso da altri)',
      () async {
        when(
          mockUserRepository.findUserById(testUserId),
        ).thenAnswer((_) async => currentUserData);

        when(
          mockUserRepository.findUserByPhone('3339999999'),
        ).thenAnswer((_) async => {'id': 456});

        expect(
          await profileService.updateAnagrafica(
            testUserId,
            telefono: '3339999999',
          ),
          false,
        );
      },
    );

    // =================================================================
    // GRUPPO 3: LOGICA DI BUSINESS & AGGIORNAMENTO (TF5, TF6, TF13)
    // =================================================================

    test(
      'TF5: Deve aggiornare solo campi non null (Update Parziale)',
      () async {
        when(
          mockUserRepository.findUserById(testUserId),
        ).thenAnswer((_) async => currentUserData);

        expect(
          await profileService.updateAnagrafica(testUserId, nome: 'Luigi'),
          true,
        );

        final captured = verify(
          mockUserRepository.updateUserGeneric(testUserId, captureAny),
        ).captured.first;

        expect(captured['nome'], 'Luigi');
        expect(captured.containsKey('email'), false); // Non deve sovrascrivere
      },
    );

    test('TF6: Deve permettere cambio email valido', () async {
      when(
        mockUserRepository.findUserById(testUserId),
      ).thenAnswer((_) async => currentUserData);
      when(
        mockUserRepository.findUserByEmail('new@test.com'),
      ).thenAnswer((_) async => null);

      expect(
        await profileService.updateAnagrafica(
          testUserId,
          email: 'new@test.com',
        ),
        true,
      );
    });

    test('TF13: Full Update (Tutti i campi insieme con dati validi)', () async {
      when(
        mockUserRepository.findUserById(testUserId),
      ).thenAnswer((_) async => currentUserData);
      when(
        mockUserRepository.findUserByEmail(any),
      ).thenAnswer((_) async => null);
      when(
        mockUserRepository.findUserByPhone(any),
      ).thenAnswer((_) async => null);

      // Usiamo un numero valido (10 cifre)
      final res = await profileService.updateAnagrafica(
        testUserId,
        nome: 'Luigi',
        cognome: 'Verdi',
        citta: 'Roma',
        email: 'luigi.verdi@test.com',
        telefono: '3331234567',
        dataNascita: DateTime(2000, 1, 1),
      );

      expect(res, true);

      final captured = verify(
        mockUserRepository.updateUserGeneric(any, captureAny),
      ).captured.first;
      expect(captured.length, 6); // Verifica che ci siano tutti e 6 i campi
    });

    // =================================================================
    // GRUPPO 4: QUALITÀ DEI DATI & NORMALIZZAZIONE (TF7, TF9, TF12, TF16)
    // =================================================================

    test('TF7: Deve pulire il telefono (rimuovere spazi)', () async {
      when(
        mockUserRepository.findUserById(testUserId),
      ).thenAnswer((_) async => currentUserData);
      // Simula check duplicati su numero pulito
      when(
        mockUserRepository.findUserByPhone('3331234567'),
      ).thenAnswer((_) async => null);

      await profileService.updateAnagrafica(
        testUserId,
        telefono: '333 123 4567',
      );

      final captured = verify(
        mockUserRepository.updateUserGeneric(any, captureAny),
      ).captured.first;
      expect(captured['telefono'], '3331234567');
    });

    test('TF9: Deve serializzare correttamente la Data di Nascita', () async {
      when(
        mockUserRepository.findUserById(testUserId),
      ).thenAnswer((_) async => currentUserData);
      final date = DateTime(1990, 1, 1);

      await profileService.updateAnagrafica(testUserId, dataNascita: date);

      final captured = verify(
        mockUserRepository.updateUserGeneric(any, captureAny),
      ).captured.first;
      expect(captured['dataDiNascita'], date.toIso8601String());
    });

    test('TF12: Deve salvare l\'email in minuscolo', () async {
      when(
        mockUserRepository.findUserById(testUserId),
      ).thenAnswer((_) async => currentUserData);
      when(
        mockUserRepository.findUserByEmail('mario@test.com'),
      ).thenAnswer((_) async => null);

      await profileService.updateAnagrafica(
        testUserId,
        email: 'Mario@Test.Com',
      );

      final captured = verify(
        mockUserRepository.updateUserGeneric(any, captureAny),
      ).captured.first;
      expect(captured['email'], 'mario@test.com');
    });

    test(
      'TF16: Deve supportare numeri internazionali con prefisso (+39)',
      () async {
        final String rawInternationalPhone = '+39 333 1234567';
        final String expectedPhone = '+393331234567';

        when(
          mockUserRepository.findUserById(testUserId),
        ).thenAnswer((_) async => currentUserData);
        when(
          mockUserRepository.findUserByPhone(expectedPhone),
        ).thenAnswer((_) async => null);

        expect(
          await profileService.updateAnagrafica(
            testUserId,
            telefono: rawInternationalPhone,
          ),
          true,
        );

        final captured = verify(
          mockUserRepository.updateUserGeneric(any, captureAny),
        ).captured.first;
        expect(captured['telefono'], expectedPhone);
      },
    );

    // =================================================================
    // GRUPPO 5: ROBUSTNESS - FORMATI INVALIDI (TF17, TF18)
    // =================================================================

    test('TF17: Deve fallire se l\'email non ha un formato valido', () async {
      when(
        mockUserRepository.findUserById(testUserId),
      ).thenAnswer((_) async => currentUserData);

      // Caso A: Stringa semplice
      expect(
        await profileService.updateAnagrafica(testUserId, email: 'mariorossi'),
        false,
      );
      // Caso B: Senza dominio
      expect(
        await profileService.updateAnagrafica(testUserId, email: 'mario@'),
        false,
      );

      verifyNever(mockUserRepository.updateUserGeneric(any, any));
    });

    test('TF18: Deve fallire se il telefono non rispetta il formato', () async {
      when(
        mockUserRepository.findUserById(testUserId),
      ).thenAnswer((_) async => currentUserData);

      // Caso A: Contiene lettere
      expect(
        await profileService.updateAnagrafica(
          testUserId,
          telefono: '333abc4567',
        ),
        false,
      );
      // Caso B: Troppo corto (es. meno di 5/10 cifre)
      expect(
        await profileService.updateAnagrafica(testUserId, telefono: '12345'),
        false,
      );

      verifyNever(mockUserRepository.updateUserGeneric(any, any));
    });

    // =================================================================
    // GRUPPO 6: EDGE CASES & STABILITÀ (TF8, TF10, TF11, TF14, TF15)
    // =================================================================

    test('TF8: Idempotenza (Ignora update se dati identici)', () async {
      when(
        mockUserRepository.findUserById(testUserId),
      ).thenAnswer((_) async => currentUserData);

      // Invio la stessa email -> non deve scattare il controllo duplicati
      await profileService.updateAnagrafica(
        testUserId,
        email: 'user@example.com',
        nome: 'NewName',
      );

      verifyNever(mockUserRepository.findUserByEmail(any));

      final captured = verify(
        mockUserRepository.updateUserGeneric(any, captureAny),
      ).captured.first;
      expect(captured.containsKey('email'), false);
    });

    test('TF10: Chiamata vuota (Nessun parametro)', () async {
      when(
        mockUserRepository.findUserById(testUserId),
      ).thenAnswer((_) async => currentUserData);

      expect(await profileService.updateAnagrafica(testUserId), true);
      verifyNever(mockUserRepository.updateUserGeneric(any, any));
    });

    test('TF11: Gestione Crash Database', () async {
      when(
        mockUserRepository.findUserById(testUserId),
      ).thenAnswer((_) async => currentUserData);
      when(
        mockUserRepository.updateUserGeneric(any, any),
      ).thenThrow(Exception('DB Error'));

      expect(
        await profileService.updateAnagrafica(testUserId, nome: 'A'),
        false,
      );
    });

    test(
      'TF14: Self-Correction (Correzione proprio numero senza errore duplicato)',
      () async {
        // PREPARAZIONE: Usiamo un numero valido (10 cifre) per passare la Regex.
        // Supponiamo che l'utente abbia nel DB il numero "3331234567"
        final existingUserData = {...currentUserData, 'telefono': '3331234567'};

        when(
          mockUserRepository.findUserById(testUserId),
        ).thenAnswer((_) async => existingUserData);

        // Il DB trova che il numero '3331234567' appartiene proprio a ID 123
        when(
          mockUserRepository.findUserByPhone('3331234567'),
        ).thenAnswer((_) async => {'id': testUserId});

        // AZIONE: L'utente reinvia il suo stesso numero (es. per correggere formattazione o per errore)
        final result = await profileService.updateAnagrafica(
          testUserId,
          telefono: '3331234567',
        );

        // VERIFICA: Deve tornare true, NON false per duplicato
        expect(result, true);
      },
    );

    test('TF15: Ignora stringhe vuote', () async {
      when(
        mockUserRepository.findUserById(testUserId),
      ).thenAnswer((_) async => currentUserData);

      await profileService.updateAnagrafica(
        testUserId,
        nome: 'Ok',
        email: '',
        telefono: '',
      );

      final captured = verify(
        mockUserRepository.updateUserGeneric(any, captureAny),
      ).captured.first;

      expect(captured['nome'], 'Ok');
      expect(captured.containsKey('email'), false);
      expect(captured.containsKey('telefono'), false);
    });
  });
}
