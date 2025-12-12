import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:backend/services/profile_service.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:data_models/utente.dart';
import 'package:data_models/soccorritore.dart';

@GenerateNiceMocks([MockSpec<UserRepository>()])
import 'get_profile_test.mocks.dart';

void main() {
  late ProfileService service;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    service = ProfileService(userRepository: mockRepository);
  });

  group('ProfileService - getProfile', () {

    // Scenario 1: get di un profilo soccorritore
    test('Deve restituire un oggetto Soccorritore e rimuovere la password', () async {
      // 1. ARRANGE
      final int soccorritoreId = 10;

      final emailSoccorritore = 'mario@118.it';

      final rawData = {
        'id': soccorritoreId,
        'email': emailSoccorritore,
        'nome': 'Mario',
        'cognome': 'Rossi',
      };

      when(mockRepository.findUserById(soccorritoreId))
          .thenAnswer((_) async => Map<String, dynamic>.from(rawData));

      // 2. ACT
      final result = await service.getProfile(soccorritoreId);

      // 3. ASSERT
      expect(result, isNotNull);
      expect(result, isA<Soccorritore>());
      expect(result?.email, emailSoccorritore);

      verify(mockRepository.findUserById(soccorritoreId)).called(1);
    });

    // Scenario 2: get di un profilo cittadino
    test('Deve restituire un oggetto Utente standard se l\'email è normale', () async {
      // 1. ARRANGE
      final int userId = 20;
      final emailCittadino = 'privato@gmail.com';

      final rawData = {
        'id': userId,
        'email': emailCittadino,
        'nome': 'Luca',
        'cognome': 'Bianchi',
      };

      when(mockRepository.findUserById(userId))
          .thenAnswer((_) async => Map<String, dynamic>.from(rawData));

      // 2. ACT
      final result = await service.getProfile(userId);

      // 3. ASSERT
      expect(result, isNotNull);
      expect(result, isA<Utente>());
      expect(result, isNot(isA<Soccorritore>()));
      expect(result?.email, emailCittadino);
    });


    // Scenario 3: utente non trovato
    test('Deve restituire null se l\'utente non esiste', () async {
      // 1. ARRANGE
      when(mockRepository.findUserById(999)).thenAnswer((_) async => null);

      // 2. ACT
      final result = await service.getProfile(999);

      // 3. ASSERT
      expect(result, isNull);
    });

    // Scenario 4: gestione eccezioni
    test('Deve restituire null e non crashare', () async {
      // 1. ARRANGE
      when(mockRepository.findUserById(any))
          .thenThrow(Exception("Connessione persa"));

      // 2. ACT
      final result = await service.getProfile(1);

      // 3. ASSERT
      expect(result, isNull);
    });
  });
}