import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

import 'package:backend/services/report_service.dart';
import 'package:backend/repositories/report_repository.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/notification_service.dart';

@GenerateMocks([
  ReportRepository,
  NotificationService,
  UserRepository,
  http.Client
])
import 'report_service_test.mocks.dart';

void main() {
  late ReportService reportService;
  late MockReportRepository mockReportRepo;
  late MockNotificationService mockNotificationService;
  late MockUserRepository mockUserRepo;
  late MockClient mockHttpClient;

  setUp(() {
    mockReportRepo = MockReportRepository();
    mockNotificationService = MockNotificationService();
    mockUserRepo = MockUserRepository();
    mockHttpClient = MockClient();

    // Reset per garantire test puliti e prevenire errori "Verification in progress"
    reset(mockReportRepo);
    reset(mockNotificationService);
    reset(mockUserRepo);
    reset(mockHttpClient);

    reportService = ReportService(
      reportRepository: mockReportRepo,
      notificationService: mockNotificationService,
      userRepo: mockUserRepo,
      httpClient: mockHttpClient,
    );
  });

  group('ReportService - 6 Scenari Strategici', () {

    const int senderId = 123;
    const double lat = 40.0;
    const double lng = 14.0;

    //TEST 1: CITTADINO
    test('1. Cittadino : Report salvato e Soccorritori notificati', () async {
      // Arrange
      when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
          encoding: anyNamed('encoding')
      )).thenAnswer((_) async => http.Response('{"analyzed_reports": [{"risk_score": 1}]}', 200));

      when(mockUserRepo.getRescuerTokens(excludedId: anyNamed('excludedId')))
          .thenAnswer((_) async => ['token_soccorritore']);

      // Act
      await reportService.createReport(
          senderId: senderId, isSenderRescuer: false, type: "Incendio", description: "Fuoco vivo",
          lat: lat, lng: lng, severity: 3
      );

      // Assert
      verify(mockReportRepo.createReport(any, any)).called(1);
      verify(mockReportRepo.createAnalyzedReport(any)).called(1);
      verify(mockNotificationService.sendBroadcast(
          title: anyNamed('title'),
          body: "Fuoco vivo",
          tokens: ['token_soccorritore'],
          type: anyNamed('type')
      )).called(1);
    });

    //TEST 2: SOCCORRITORE
    test('2. Soccorritore (Happy Path): Allerta salvata e Cittadini notificati', () async {
      // Arrange
      when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
          encoding: anyNamed('encoding')
      )).thenAnswer((_) async => http.Response('{"analyzed_reports": [{"risk_score": 1}]}', 200));

      when(mockUserRepo.getCitizenTokens(excludedId: anyNamed('excludedId')))
          .thenAnswer((_) async => ['token_cittadino']);

      // Act
      await reportService.createReport(
          senderId: senderId, isSenderRescuer: true, type: "Alluvione", description: "Evacuare",
          lat: lat, lng: lng, severity: 5
      );

      // Assert
      verify(mockReportRepo.createReport(any, any)).called(1);
      verify(mockUserRepo.getCitizenTokens(excludedId: senderId)).called(1);
      // Verifica che NON chiami i soccorritori
      verifyNever(mockUserRepo.getRescuerTokens(excludedId: anyNamed('excludedId')));
    });

    // --- TEST 3: VALIDAZIONE (Descrizione Mancante) ---
    test('3. Validazione: Descrizione NULL -> Nessun salvataggio', () async {
      // Act
      try {
        await reportService.createReport(
            senderId: senderId, isSenderRescuer: false, type: "Incendio", description: null,
            lat: lat, lng: lng, severity: 3
        );
      } catch (e) { /* Ignora eccezione prevista */ }

      // Assert
      verifyNever(mockReportRepo.createReport(any, any));
      verifyNever(mockNotificationService.sendBroadcast(
          title: anyNamed('title'), body: anyNamed('body'), tokens: anyNamed('tokens')
      ));
    });

    // --- TEST 4: ROBUSTEZZA (AI Down - Cittadino) ---
    test('4. Robustezza: Errore AI (500) -> Salva solo report base', () async {
      // Arrange
      when(mockReportRepo.createReport(any, any)).thenAnswer((_) async {});

      // AI Error Stubbing
      when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
          encoding: anyNamed('encoding')
      )).thenAnswer((_) async => http.Response('Internal Server Error', 500));

      when(mockUserRepo.getRescuerTokens(excludedId: anyNamed('excludedId')))
          .thenAnswer((_) async => ['tok']);

      // Act
      await reportService.createReport(
          senderId: senderId, isSenderRescuer: false, type: "Incendio", description: "Test",
          lat: lat, lng: lng, severity: 3
      );

      // Assert
      verify(mockReportRepo.createReport(any, any)).called(1);
      verifyNever(mockReportRepo.createAnalyzedReport(any)); // AI Fallita -> No Analyzed Report

      // Notifica deve partire comunque
      verify(mockNotificationService.sendBroadcast(
          title: anyNamed('title'),
          body: anyNamed('body'),
          tokens: ['tok'],
          type: anyNamed('type')
      )).called(1);
    });

    // --- TEST 5: ROBUSTEZZA (AI Down - Soccorritore) ---
    test('5. Robustezza: Soccorritore con AI Down -> Allerta inviata comunque', () async {
      // Arrange
      when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
          encoding: anyNamed('encoding')
      )).thenAnswer((_) async => http.Response('Error', 500));

      when(mockUserRepo.getCitizenTokens(excludedId: anyNamed('excludedId')))
          .thenAnswer((_) async => ['tok']);

      // Act
      await reportService.createReport(
          senderId: senderId, isSenderRescuer: true, type: "Alluvione", description: "Test",
          lat: lat, lng: lng, severity: 5
      );

      // Assert
      verify(mockReportRepo.createReport(any, any)).called(1);
      verifyNever(mockReportRepo.createAnalyzedReport(any));
      verify(mockNotificationService.sendBroadcast(
          title: anyNamed('title'),
          body: anyNamed('body'),
          tokens: ['tok'],
          type: anyNamed('type')
      )).called(1);
    });

    // --- TEST 6: DESTINATARI VUOTI ---
    test('6. Edge Case: Nessun destinatario trovato -> Nessuna notifica', () async {
      // Arrange
      when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
          encoding: anyNamed('encoding')
      )).thenAnswer((_) async => http.Response('{"analyzed_reports": []}', 200));

      // Lista vuota
      when(mockUserRepo.getRescuerTokens(excludedId: anyNamed('excludedId')))
          .thenAnswer((_) async => []);

      // Act
      await reportService.createReport(
          senderId: senderId, isSenderRescuer: false, type: "Incendio", description: "Deserto",
          lat: lat, lng: lng, severity: 3
      );

      // Assert
      verify(mockReportRepo.createReport(any, any)).called(1);

      verifyNever(mockNotificationService.sendBroadcast(
          title: anyNamed('title'),
          body: anyNamed('body'),
          tokens: anyNamed('tokens'),
          type: anyNamed('type')
      ));
    });

  });
}