import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/repositories/profile_repository.dart';
import 'package:data_models/UtenteGenerico.dart';

class GestioneModificaProfiloCittadino extends StatefulWidget {
  const GestioneModificaProfiloCittadino({super.key});

  @override
  State<GestioneModificaProfiloCittadino> createState() =>
      _GestioneModificaProfiloCittadinoState();
}

class _GestioneModificaProfiloCittadinoState
    extends State<GestioneModificaProfiloCittadino> {

  // Repository locale
  final ProfileRepository _profileRepository = ProfileRepository();

  late TextEditingController _nomeController;
  late TextEditingController _cognomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _indirizzoController; // Useremo questo per la Città

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // 1. Recupera l'utente corrente dal Provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final UtenteGenerico? user = authProvider.currentUser;

    // 2. Inizializza i controller con i dati reali (o stringa vuota se null)
    _nomeController = TextEditingController(text: user?.nome ?? "");
    _cognomeController = TextEditingController(text: user?.cognome ?? "");
    _emailController = TextEditingController(text: user?.email ?? "");
    _telefonoController = TextEditingController(text: user?.telefono ?? "");
    _indirizzoController = TextEditingController(text: user?.cittaDiNascita ?? "");
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _indirizzoController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      await _profileRepository.updateAnagrafica(
        nome: _nomeController.text.trim(),
        cognome: _cognomeController.text.trim(),
        telefono: _telefonoController.text.trim(), // Telefono ora viene inviato
        email: _emailController.text.trim(),       // Email ora viene inviata
        citta: _indirizzoController.text.trim(),
      );

      // Aggiorniamo subito anche i dati locali nel provider per vederli nella Home
      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).updateUserLocally(
          nome: _nomeController.text.trim(),
          cognome: _cognomeController.text.trim(),
          telefono: _telefonoController.text.trim(),
          // Per l'email, siccome AuthProvider non ha il campo 'email' nel metodo updateUserLocally
          // che abbiamo creato prima, è meglio chiamare reloadUser()
        );

        // Ricarica tutto il profilo dal server per sicurezza (specie per l'email)
        await Provider.of<AuthProvider>(context, listen: false).reloadUser();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profilo aggiornato con successo!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Errore: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF12345A);
    const Color cardColor = Color(0xFF0E2A48);
    const Color accentColor = Color(0xFFEF923D);
    const Color iconColor = Color(0xFFE3C63D);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.person_outline,
                      color: iconColor,
                      size: 40,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Modifica\nProfilo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              // FORM CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.camera_alt,
                        size: 30,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildField("Nome", _nomeController),
                    _buildField("Cognome", _cognomeController),

                    // L'email è spesso immutabile o richiede procedure speciali,
                    // la mettiamo readOnly per sicurezza visiva.
                    _buildField("Email", _emailController, isEmail: true),

                    _buildField("Telefono", _telefonoController, isPhone: true),
                    _buildField("Città", _indirizzoController),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _isLoading ? null : _saveProfile,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "SALVA MODIFICHE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      String label,
      TextEditingController controller, {
        bool isEmail = false,
        bool isPhone = false,
        bool isReadOnly = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            readOnly: isReadOnly,
            keyboardType: isEmail
                ? TextInputType.emailAddress
                : (isPhone ? TextInputType.phone : TextInputType.text),
            style: TextStyle(
                color: isReadOnly ? Colors.white54 : Colors.white
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black12,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}