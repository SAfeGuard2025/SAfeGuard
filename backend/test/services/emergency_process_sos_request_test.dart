import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Import delle classi reali (Assicurati che i path siano corretti nel tuo progetto)
import 'package:backend/services/emergency_service.dart';
import 'package:backend/repositories/emergency_repository.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/notification_service.dart';

// Generazione Mock per le dipendenze
@GenerateNiceMocks([
  MockSpec<EmergencyRepository>(),
  MockSpec<NotificationService>(),
  MockSpec<UserRepository>(),
])
// Import del file generato da mockito (da lanciare con `dart run build_runner build`)
import 'emergency_process_sos_request_test.mocks.dart';

void main() {
  late EmergencyService emergencyService;
  late MockEmergencyRepository mockRepo;
  late MockNotificationService mockNotif;
  late MockUserRepository mockUserRepo;

  // Costanti per coordinate valide (Esempio: Centro di Salerno)
  const validLat = 40.6824;
  const validLng = 14.7681;

  // Costanti per coordinate fuori Salerno (Esempio: Roma)
  const outOfAreaLat = 41.9028;
  const outOfAreaLng = 12.4964;

  // Setup: Iniezione delle dipendenze mockate (come in loginemail_service_test.dart)
  setUp(() {
    mockRepo = MockEmergencyRepository();
    mockNotif = MockNotificationService();
    mockUserRepo = MockUserRepository();

    // Iniezione delle dipendenze mockate nel Service
    emergencyService = EmergencyService(
      repository: mockRepo,
      notificationService: mockNotif,
      userRepo: mockUserRepo,
    );

    // Stubbing comune per il repository: Risposta di successo
    when(mockRepo.sendSos(
      userId: anyNamed('userId'),
      email: anyNamed('email'),
      phone: anyNamed('phone'),
      type: anyNamed('type'),
      lat: anyNamed('lat'),
      lng: anyNamed('lng'),
    )).thenAnswer((_) async => Future.value());

    // Stubbing comune per le notifiche (per non fallire i test sulle interazioni)
    when(mockUserRepo.getRescuerTokens(excludedId: anyNamed('excludedId')))
        .thenAnswer((_) async => ['token_abc']);
    when(mockNotif.sendBroadcast(
      title: anyNamed('title'),
      body: anyNamed('body'),
      tokens: anyNamed('tokens'),
      type: anyNamed('type'),
    )).thenAnswer((_) async => Future.value());
  });

  group('EmergencyService - processSosRequest', () {

    // --- Casi di Successo ---

    // TEST CASE: TU_SOS_1 (Tutto Valido)
    test('1. Deve inviare SOS correttamente quando tutti i dati sono validi (Salerno, +39, @)', () async {
      // 1. ARRANGE
      const userId = 'user_full';
      const phone = '+393339999999';
      const email = 'valid@test.com';
      const type = 'Medico';

      // 2. ACT
      await emergencyService.processSosRequest(
        userId: userId,
        email: email,
        phone: phone,
        type: type,
        lat: validLat,
        lng: validLng,
      );

      // 3. ASSERT
      // Verifica che il repository sia chiamato esattamente con i dati forniti
      verify(mockRepo.sendSos(
        userId: userId,
        email: email,
        phone: phone,
        type: type,
        lat: validLat,
        lng: validLng,
      )).called(1);
      verify(mockNotif.sendBroadcast(
        title: anyNamed('title'),
        body: anyNamed('body'),
        tokens: anyNamed('tokens'),
        type: anyNamed('type'),
      )).called(1);
    });

    // TEST CASE: TU_SOS_2 (Input Nulli)
    test('2. Deve accettare email e telefono NULL e convertirli in "N/A"', () async {
      // 1. ARRANGE
      const userId = 'user_anon';

      // 2. ACT
      await emergencyService.processSosRequest(
        userId: userId,
        email: null,
        phone: null,
        type: 'Incendio',
        lat: validLat,
        lng: validLng,
      );

      // 3. ASSERT
      // Verifica che il service abbia convertito null in "N/A" come previsto
      verify(mockRepo.sendSos(
        userId: userId,
        email: 'N/A',
        phone: 'N/A',
        type: 'Incendio',
        lat: validLat,
        lng: validLng,
      )).called(1);
    });

    // TEST CASE: TU_SOS_6 (Normalizzazione Type)
    test('3. Deve normalizzare il tipo SOS a "Generico" se non in lista', () async {
      // 1. ARRANGE
      const weirdType = 'Terremoto'; // Non presente in allowedTypes  [cite: 27-34]

      // 2. ACT
      await emergencyService.processSosRequest(
        userId: 'user_1',
        email: 'valid@test.com',
        phone: '+390000000000',
        type: weirdType,
        lat: validLat,
        lng: validLng,
      );

      // 3. ASSERT
      // Verifica che il repository riceva 'Generico'
      verify(mockRepo.sendSos(
        userId: anyNamed('userId'),
        email: anyNamed('email'),
        phone: anyNamed('phone'),
        type: 'Generico', // Verifica normalizzazione
        lat: anyNamed('lat'),
        lng: anyNamed('lng'),
      )).called(1);
    });

    // --- Casi di Fallimento (Validazione) ---

    // TEST CASE: TU_SOS_8 (UserId Mancante)
    test('4. Deve lanciare ArgumentError se userId è vuoto', () async {
      // 2. ACT & 3. ASSERT
      expect(
            () async => await emergencyService.processSosRequest(
          userId: '', // INVALIDO [cite: 24]
          email: null,
          phone: null,
          type: 'Generico',
          lat: validLat,
          lng: validLng,
        ),
        throwsA(predicate((e) => e.toString().contains('ID Utente mancante'))),
      );
    });

    // TEST CASE: TU_SOS_7 (GPS Global Invalido)
    test('5. Deve lanciare ArgumentError se coordinate GPS non sono valide (fuori range globale)', () async {
      // 2. ACT & 3. ASSERT
      expect(
            () async => await emergencyService.processSosRequest(
          userId: 'user_fail_gps',
          email: null,
          phone: null,
          type: 'Generico',
          lat: 100.0, // INVALIDO (Lat > 90) [cite: 21]
          lng: 12.0,
        ),
        throwsA(predicate((e) => e.toString().contains('Coordinate GPS non valide'))),
      );
    });

    // TEST CASE: TU_SOS_5 (Fuori Area Salerno - Richiesto)
    test('6. Deve lanciare ArgumentError se coordinate sono fuori Salerno (Assunzione di validazione aggiunta)', () async {
      // 2. ACT & 3. ASSERT
      // Assumiamo che il service lanci un ArgumentError specifico per l'area non coperta
      expect(
            () async => await emergencyService.processSosRequest(
          userId: 'user_roma',
          email: 'valid@test.com',
          phone: '+393331111111',
          type: 'Generico',
          lat: outOfAreaLat,
          lng: outOfAreaLng,
        ),
        // Verifica che venga lanciato un ArgumentError
        throwsArgumentError,
      );
    });

    // TEST CASE: TU_SOS_3 (Telefono Invalido se presente)
    test('7. Deve lanciare ArgumentError se il telefono è presente ma senza +39 (Assunzione di validazione aggiunta)', () async {
      // 2. ACT & 3. ASSERT
      expect(
            () async => await emergencyService.processSosRequest(
          userId: 'user_fail_phone',
          email: null,
          phone: '3331234567', // MANCA +39
          type: 'Generico',
          lat: validLat,
          lng: validLng,
        ),
        throwsArgumentError,
      );
    });

    // TEST CASE: TU_SOS_4 (Email Invalida se presente)
    test('8. Deve lanciare ArgumentError se l\'email è presente ma malformata (Assunzione di validazione aggiunta)', () async {
      // 2. ACT & 3. ASSERT
      expect(
            () async => await emergencyService.processSosRequest(
          userId: 'user_fail_email',
          email: 'mariorossi.it', // MANCA @
          phone: null,
          type: 'Generico',
          lat: validLat,
          lng: validLng,
        ),
        throwsArgumentError,
      );
    });
  });

  // TEST CASE: TU_SOS_9 (Type Vuoto/Whitespace)
  test('9. Deve normalizzare un tipo SOS vuoto (ad esempio "") a "Generico"', () async {
    // 1. ARRANGE
    const emptyType = ''; // Stringa vuota
    // La logica di normalizzazione considera i tipi non consentiti o non validi come 'Generico'
    // La lista `allowedTypes` non contiene l'empty string, quindi dovrebbe fallire il controllo `allowedTypes.contains(type)`.

    // 2. ACT
    await emergencyService.processSosRequest(
      userId: 'user_empty_type',
      email: null,
      phone: null,
      type: emptyType, // INVALIDO
      lat: validLat,
      lng: validLng,
    );

    // 3. ASSERT
    // Verifica che il repository riceva 'Generico'
    verify(mockRepo.sendSos(
      userId: anyNamed('userId'),
      email: anyNamed('email'),
      phone: anyNamed('phone'),
      type: 'Generico', // Verifica normalizzazione da stringa vuota
      lat: anyNamed('lat'),
      lng: anyNamed('lng'),
    )).called(1);
  });

  // TEST CASE: TU_SOS_10 (Coordinate al Limite Estremo Valido - Salerno)
  test('10. Deve accettare coordinate al limite massimo valido dell\'area operativa di Salerno', () async {
    // 1. ARRANGE
    const salernoLatMax = 40.80; // Limite superiore valido di Salerno
    const salernoLngMax = 14.90; // Limite superiore valido di Salerno

    // 2. ACT
    await emergencyService.processSosRequest(
      userId: 'user_salerno_limit',
      email: null,
      phone: null,
      type: 'Medico',
      lat: salernoLatMax, // Limite superiore valido di Salerno
      lng: salernoLngMax, // Limite superiore valido di Salerno
    );

    // 3. ASSERT
    // Verifica che il repository sia chiamato
    verify(mockRepo.sendSos(
      userId: anyNamed('userId'),
      email: anyNamed('email'),
      phone: anyNamed('phone'),
      type: anyNamed('type'),
      lat: salernoLatMax,
      lng: salernoLngMax,
    )).called(1);
    });
}