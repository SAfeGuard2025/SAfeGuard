import 'package:test/test.dart'; // O flutter_test se sei in app mobile
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:backend/services/sms_service.dart';
import 'package:backend/services/email_service.dart';
import 'package:backend/repositories/user_repository.dart';

// Generazione dei Mock
@GenerateNiceMocks([MockSpec<EmailService>(), MockSpec<UserRepository>()])
import 'sms_service_test.mocks.dart';

void main() {
  late SmsService smsService;
  late MockEmailService mockEmailService;
  late MockUserRepository mockUserRepository;

  // Setup Iniziale del Test
  setUp(() {
    mockEmailService = MockEmailService();
    mockUserRepository = MockUserRepository();

    // Iniezione delle dipendenze e mail di simulazione
    // per testare il ramo che invia l'email
    smsService = SmsService(
      emailService: mockEmailService,
      userRepository: mockUserRepository,
      //Si forza l'email di simulazione
      simulationEmail: 'admin@test.com',
    );
  });

  group('SmsService - Metodo sendOtp', () {
    // Scenario 1: Successo (Formato ok, Utente Esiste, OTP ok)
    test(
      'Deve inviare email di simulazione se i dati sono validi e utente esiste',
      () async {
        // arrange
        const telefono = '+393331234567';
        const otp = '123456';

        // Simuliamo che l'utente esista nel DB
        when(
          mockUserRepository.findUserByPhone(telefono),
        ).thenAnswer((_) async => {'id': 1, 'nome': 'Test'});

        // Invio email con successo
        when(
          mockEmailService.send(
            to: anyNamed('to'),
            subject: anyNamed('subject'),
            htmlContent: anyNamed('htmlContent'),
          ),
        ).thenAnswer((_) async => {});

        // act
        await smsService.sendOtp(telefono, otp);

        // assert
        // Verifica che il repository sia stato interrogato
        verify(mockUserRepository.findUserByPhone(telefono)).called(1);

        // Verifica che l'email sia stata inviata all'indirizzo di simulazione
        verify(
          mockEmailService.send(
            to: 'admin@test.com',
            subject: argThat(contains(telefono), named: 'subject'),
            htmlContent: argThat(contains(otp), named: 'htmlContent'),
          ),
        ).called(1);
      },
    );

    // Scenario 2: Formato Telefono non valido
    test(
      'Deve lanciare ArgumentError se il formato del telefono è errato',
      () async {
        // arrange
        const telefonoErrato = '12345'; // Manca il +
        const otp = '123456';

        // act e assert
        expect(
          () async => await smsService.sendOtp(telefonoErrato, otp),
          throwsArgumentError,
        );

        // Verifica che non si sia provato a cercare nel DB o di inviare l'email
        verifyNever(mockUserRepository.findUserByPhone(any));
        verifyNever(
          mockEmailService.send(
            to: anyNamed('to'),
            subject: anyNamed('subject'),
            htmlContent: anyNamed('htmlContent'),
          ),
        );
      },
    );

    // Scenario 3: Formato OTP non valido
    test('Deve lanciare ArgumentError se l\'OTP non ha 6 cifre', () async {
      // arrange
      const telefono = '+393331234567';
      const otpErrato = '123';

      // act e assert
      expect(
        () async => await smsService.sendOtp(telefono, otpErrato),
        throwsArgumentError,
      );
    });

    // Scenario 4: Utente non trovato nel DB
    test(
      'Deve lanciare Exception se il numero di telefono non esiste nel DB',
      () async {
        // arrange
        const telefono = '+393339999999';
        const otp = '123456';

        // Il DB restituisce null (Utente non trovato)
        when(
          mockUserRepository.findUserByPhone(telefono),
        ).thenAnswer((_) async => null);

        // act e assert
        expect(
          () async => await smsService.sendOtp(telefono, otp),
          throwsA(predicate((e) => e.toString().contains('non trovato'))),
        );

        verify(mockUserRepository.findUserByPhone(telefono)).called(1);
        verifyNever(
          mockEmailService.send(
            to: anyNamed('to'),
            subject: anyNamed('subject'),
            htmlContent: anyNamed('htmlContent'),
          ),
        );
      },
    );
  });
}
