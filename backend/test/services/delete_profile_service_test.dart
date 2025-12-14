import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:backend/services/profile_service.dart';
import 'package:backend/repositories/user_repository.dart';

// Generazione del Mock
@GenerateNiceMocks([MockSpec<UserRepository>()])
import 'delete_profile_service_test.mocks.dart';

void main() {
  late ProfileService profileService;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();

    resetMockitoState();

    // Iniezione del mock nel service
    profileService = ProfileService(userRepository: mockUserRepository);
  });

  group('ProfileService - Metodo deleteAccount', () {
    // Scenario 1: Eliminazione riuscita
    test(
      'Deve restituire TRUE quando il repository elimina l\'utente con successo',
      () async {
        // arrange
        const userId = 999;

        // Simuliamo che il repository faccia il suo lavoro senza errori.
        // Se UserRepository.deleteUser restituisce Future<bool>:
        when(
          mockUserRepository.deleteUser(userId),
        ).thenAnswer((_) async => true);

        // act
        final result = await profileService.deleteAccount(userId);

        // assert
        expect(result, isTrue);
        verify(mockUserRepository.deleteUser(userId)).called(1);
      },
    );

    // Scenario 2: Errore durante l'eliminazione
    test('Deve restituire FALSE se il repository lancia un errore', () async {
      // arrange
      const userId = 888;

      //Eccezione dal database
      when(
        mockUserRepository.deleteUser(userId),
      ).thenThrow(Exception('Errore DB'));

      // act
      final result = await profileService.deleteAccount(userId);

      // assert
      expect(result, isFalse);
      verify(mockUserRepository.deleteUser(userId)).called(1);
    });
  });
}
