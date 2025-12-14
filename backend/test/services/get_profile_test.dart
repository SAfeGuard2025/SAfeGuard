import 'package:test/test.dart';
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

    service = ProfileService(
      userRepository: mockRepository,
      validator: (String email) =>
      email.endsWith('118.it') || email.endsWith('crocerossa.it'),
    );
  });

  group('ProfileService - getProfile', () {

    // [TU_PRO_1] Scenario 1: get di un profilo soccorritore
    test('Deve restituire un oggetto Soccorritore e rimuovere la password', () async {
      // 1. ARRANGE
      final int soccorritoreId = 10;
      final emailSoccorritore = 'mario@118.it';

      final rawData = {
        'id': soccorritoreId,
        'email': emailSoccorritore,
        'passwordHash': 'secret',
      };

      when(mockRepository.findUserById(soccorritoreId))
          .thenAnswer((_) async => Map<String, dynamic>.from(rawData));

      // 2. ACT
      final result = await service.getProfile(soccorritoreId);

      // 3. ASSERT
      expect(result, isNotNull);
      expect(result, isA<Soccorritore>());
      expect((result as Soccorritore).email, emailSoccorritore);

      verify(mockRepository.findUserById(soccorritoreId)).called(1);
    });

    // [TU_PRO_2] Scenario 2: get di un profilo cittadino
    test('Deve restituire un oggetto Utente standard se l\'email è normale', () async {
      // 1. ARRANGE
      final int userId = 20;
      final emailCittadino = 'privato@gmail.com';

      final rawData = {
        'id': userId,
        'email': emailCittadino,
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

    // [TU_PRO_3] Scenario 3: utente non trovato
    test('Deve restituire null se l\'utente non esiste', () async {
      // 1. ARRANGE
      when(mockRepository.findUserById(999)).thenAnswer((_) async => null);

      // 2. ACT
      final result = await service.getProfile(999);

      // 3. ASSERT
      expect(result, isNull);
    });

    // [TU_PRO_4] Scenario 4: restituzione corretta dei dati
    test('Deve restituire i dati giusti (nome e cognome)', () async {
      // 1. ARRANGE
      final int soccorritoreId = 10;

      final emailSoccorritore = 'mario@crocerossa.it';

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
      expect(result?.nome, 'Mario');
      expect(result?.cognome, 'Rossi');
      expect(result, isA<Soccorritore>());
      expect(result?.email, emailSoccorritore);

      verify(mockRepository.findUserById(soccorritoreId)).called(1);
    });

    // [TU_PRO_5] Scenario 5: restituzione corretta dei dati e non la password
    test('Deve restituire i dati giusti ma non la password', () async {
      // 1. ARRANGE
      final int soccorritoreId = 10;
      final emailSoccorritore = 'mario@crocerossa.it';

      final rawData = {
        'id': soccorritoreId,
        'email': emailSoccorritore,
        'nome': 'Mario',
        'cognome': 'Rossi',
        'passwordHash': '1234567890A!'
      };

      when(mockRepository.findUserById(soccorritoreId))
          .thenAnswer((_) async => Map<String, dynamic>.from(rawData));

      // 2. ACT
      final result = await service.getProfile(soccorritoreId);

      // 3. ASSERT
      expect(result, isNotNull);
      expect(result?.nome, 'Mario');
      expect(result?.cognome, 'Rossi');
      expect(result, isA<Soccorritore>());
      expect(result?.email, emailSoccorritore);

      if (result is Soccorritore) {
        expect(result.passwordHash, isNot('1234567890A!'));
      }

      verify(mockRepository.findUserById(soccorritoreId)).called(1);
    });

    // [TU_PRO_6] Scenario 6: setting della flag isSoccorritore a true mentre l'email non è istituzionale
    test('isSoccorritore settato a true mentre l\'email non è di tipo soccorritore', () async {
      // 1. ARRANGE
      final userId = 30;
      final emailCittadino = 'hacker@gmail.com';

      final rawData = {
        'id': userId,
        'email': emailCittadino,
        'nome': 'Hacker',
        'isSoccorritore': true,
        'passwordHash': 'x'
      };

      when(mockRepository.findUserById(userId))
          .thenAnswer((_) async => Map<String, dynamic>.from(rawData));

      // 2. ACT
      final result = await service.getProfile(userId);

      // 3. ASSERT
      expect(result, isA<Utente>());
      expect(result, isNot(isA<Soccorritore>()));
    });
  });
}