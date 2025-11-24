import 'package:data_models/UtenteGenerico.dart';
import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import '../repositories/UserRepository.dart';
import 'VerificationService.dart';

const String rescuerDomain = '@soccorritore.gmail';

class RegisterService {
  final UserRepository _userRepository;
  final VerificationService _verificationService;

  RegisterService(this._userRepository, this._verificationService);

  Future<UtenteGenerico> register(
    Map<String, dynamic> requestData,
    String password,
  ) async {
    final email = requestData['email'] as String?;
    final telefono =
        requestData['telefono'] as String?; // Estrae anche il telefono

    // 1. Validazione Iniziale: Almeno email o telefono deve essere fornito
    if (password.isEmpty || (email == null && telefono == null)) {
      throw Exception('Devi fornire Password e almeno Email o Telefono.');
    }

    // 2. Controllo di esistenza (per email e per telefono)
    if (email != null && await _userRepository.findUserByEmail(email) != null) {
      throw Exception('Utente con questa email è già registrato.');
    }
    if (telefono != null &&
        await _userRepository.findUserByPhone(telefono) != null) {
      throw Exception('Utente con questo telefono è già registrato.');
    }

    // 3. Prepara il payload con la password
    requestData['passwordHash'] = password;

    final UtenteGenerico newUser;

    requestData['id'] = 0; // ID 0 temporaneo
    requestData['isVerified'] = false;

    // 4. La determinazione del tipo deve usare l'email se disponibile,
    // altrimenti assume che un utente registrato solo con telefono sia standard.
    bool isSoccorritore = false;
    if (email != null) {
      isSoccorritore = email.toLowerCase().endsWith(rescuerDomain);
    }
    // NOTA: Se si registra solo con telefono, non è possibile discriminare il tipo,
    // quindi verrà trattato come Utente standard a meno che non ci sia un campo discriminante nel requestData.
    // Quindi assumiamo che la registrazione di Soccorritore debba sempre includere l'email.

    if (isSoccorritore) {
      newUser = Soccorritore.fromJson(requestData);
    } else {
      newUser = Utente.fromJson(requestData);
    }

    // 5. Salva l'utente nel Database
    final savedUser = await _userRepository.saveUser(newUser);

    //Se si usa il telefono, avvia la verifica OTP
    if (savedUser.telefono != null) {
      await _verificationService.startPhoneVerification(savedUser.telefono!);
    }

    return savedUser;
  }
}
