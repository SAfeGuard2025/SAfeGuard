import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:backend/services/verification_service.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/sms_service.dart';

// Generazione Mocks
@GenerateNiceMocks([MockSpec<UserRepository>(), MockSpec<SmsService>()])
import 'verification_service_test.mocks.dart';

void main() {
  late VerificationService verificationService;
  late MockUserRepository mockUserRepository;
  late MockSmsService mockSmsService;

  // Setup Iniziale
  setUp(() {
    mockUserRepository = MockUserRepository();
    mockSmsService = MockSmsService();

    // Reset dello stato per pulire le chiamate precedenti
    resetMockitoState();

    // Iniezione delle dipendenze
    verificationService = VerificationService(
      mockUserRepository,
      mockSmsService,
    );
  });

  group('VerificationService - Metodo completePhoneVerification', () {
    // Scenario 1: Successo (OTP Valido + Utente Esistente)
    test(
      'Deve verificare OTP e aggiornare stato utente se OTP è corretto',
      () async {
        // arrange
        const telefono = '+393331234567';
        const otp = '123456';
        const email = 'user@example.com';

        // Si simula che l'OTP sia valido
        when(
          mockUserRepository.verifyOtp(telefono, otp),
        ).thenAnswer((_) async => true);

        // Si simula il recupero dell'utente
        when(
          mockUserRepository.findUserByPhone(telefono),
        ).thenAnswer((_) async => {'email': email, 'nome': 'Test'});

        // Si simula l'aggiornamento dello stato
        when(
          mockUserRepository.markUserAsVerified(email),
        ).thenAnswer((_) async => {});

        // act
        final result = await verificationService.completePhoneVerification(
          telefono,
          otp,
        );

        // assert
        expect(result, isTrue);

        // Verifica sequenza chiamate
        verify(mockUserRepository.verifyOtp(telefono, otp)).called(1);
        verify(mockUserRepository.findUserByPhone(telefono)).called(1);

        // Verifica che venga chiamato markUserAsVerified
        verify(mockUserRepository.markUserAsVerified(email)).called(1);
      },
    );

    // Scenario 2: OTP Non Valido
    test(
      'Deve restituire false e NON aggiornare utente se OTP è errato',
      () async {
        // arrange
        const telefono = '+393331234567';
        const otpErrato = '000000';

        // OTP non valido
        when(
          mockUserRepository.verifyOtp(telefono, otpErrato),
        ).thenAnswer((_) async => false);

        // act
        final result = await verificationService.completePhoneVerification(
          telefono,
          otpErrato,
        );

        // assert
        expect(result, isFalse);

        verify(mockUserRepository.verifyOtp(telefono, otpErrato)).called(1);

        // Verifica che il flusso si sia fermato
        verifyNever(mockUserRepository.findUserByPhone(any));
        verifyNever(mockUserRepository.markUserAsVerified(any));
      },
    );

    // Scenario 3: OTP Valido ma Utente Non Trovato (es. registrazione incompleta)
    test(
      'Deve restituire true ma NON aggiornare nulla se l\'utente non esiste',
      () async {
        // arrange
        const telefono = '+393339999999';
        const otp = '123456';

        // OTP Valido
        when(
          mockUserRepository.verifyOtp(telefono, otp),
        ).thenAnswer((_) async => true);

        // Utente non trovato nel DB
        when(
          mockUserRepository.findUserByPhone(telefono),
        ).thenAnswer((_) async => null);

        // act
        final result = await verificationService.completePhoneVerification(
          telefono,
          otp,
        );

        // assert
        // L'OTP era tecnicamente valido
        expect(result, isTrue);

        verify(mockUserRepository.findUserByPhone(telefono)).called(1);

        // Verifica che non abbia provato ad aggiornare un utente inesistente
        verifyNever(mockUserRepository.markUserAsVerified(any));
      },
    );
  });
}
