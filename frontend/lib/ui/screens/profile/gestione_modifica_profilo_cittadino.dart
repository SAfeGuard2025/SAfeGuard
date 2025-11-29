import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/repositories/profile_repository.dart';
import 'package:data_models/UtenteGenerico.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Schermata Modifica Profilo Cittadino/Generico
// Permette la modifica dei dati anagrafici dell'utente.
class GestioneModificaProfiloCittadino extends StatefulWidget {
  const GestioneModificaProfiloCittadino({super.key});

  @override
  State<GestioneModificaProfiloCittadino> createState() =>
      _GestioneModificaProfiloCittadinoState();
}

class _GestioneModificaProfiloCittadinoState
    extends State<GestioneModificaProfiloCittadino> {
  // Repository per la gestione del profilo
  final ProfileRepository _profileRepository = ProfileRepository();

  // Controller per i campi di input
  late TextEditingController _nomeController;
  late TextEditingController _cognomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _indirizzoController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final UtenteGenerico? user = authProvider.currentUser;

    // Inizializza i controller con i dati attuali dell'utente
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

  // Funzione per salvare le modifiche del profilo
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      // 1. Aggiornamento sul backend tramite Repository
      await _profileRepository.updateAnagrafica(
        nome: _nomeController.text.trim(),
        cognome: _cognomeController.text.trim(),
        telefono: _telefonoController.text.trim(),
        email: _emailController.text.trim(),
        citta: _indirizzoController.text.trim(),
      );

      if (!mounted) return;

      // 2. Aggiornamento locale
      Provider.of<AuthProvider>(context, listen: false).updateUserLocally(
        nome: _nomeController.text.trim(),
        cognome: _cognomeController.text.trim(),
        telefono: _telefonoController.text.trim(),
      );

      // 3. Ricarica completa dei dati utente
      await Provider.of<AuthProvider>(context, listen: false).reloadUser();
      if (!mounted) return;

      // Notifica e navigazione
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profilo aggiornato con successo!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Logica responsive e color palette
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 700;

    final isRescuer = context.watch<AuthProvider>().isRescuer;

    Color bgColor = isRescuer ? ColorPalette.primaryOrange : ColorPalette.backgroundMidBlue;
    Color cardColor = isRescuer ? ColorPalette.cardDarkOrange: ColorPalette.backgroundDarkBlue;
    Color accentColor = isRescuer ? ColorPalette.backgroundMidBlue : ColorPalette.primaryOrange;
    const Color iconColor = ColorPalette.iconAccentYellow;

    final double titleSize = isWideScreen ? 50 : 28;
    final double iconSize = isWideScreen ? 60 : 40;

    final double labelFontSize = isWideScreen ? 24 : 14;
    final double inputFontSize = isWideScreen ? 26 : 16;
    final double buttonFontSize = isWideScreen ? 28 : 18;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [

                // Header con bottone indietro e titolo
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 16.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: isWideScreen ? 36 : 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.person_outline,
                        color: iconColor,
                        size: iconSize,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        "Modifica Profilo",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenuto centrale con form di modifica
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20.0),
                          padding: EdgeInsets.all(isWideScreen ? 40.0 : 20.0),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(25.0),
                            boxShadow: isWideScreen ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ] : [],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              // Campi Nome e Cognome (affiancati su wide screen)
                              if (isWideScreen)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildField("Nome", _nomeController, labelSize: labelFontSize, inputSize: inputFontSize)),
                                    const SizedBox(width: 30),
                                    Expanded(child: _buildField("Cognome", _cognomeController, labelSize: labelFontSize, inputSize: inputFontSize)),
                                  ],
                                )
                              else ...[
                                _buildField("Nome", _nomeController, labelSize: labelFontSize, inputSize: inputFontSize),
                                _buildField("Cognome", _cognomeController, labelSize: labelFontSize, inputSize: inputFontSize),
                              ],

                              // Campo Email
                              _buildField("Email", _emailController, isEmail: true, labelSize: labelFontSize, inputSize: inputFontSize),

                              // Campi Telefono e Città (affiancati su wide screen)
                              if (isWideScreen)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildField("Telefono", _telefonoController, isPhone: true, labelSize: labelFontSize, inputSize: inputFontSize)),
                                    const SizedBox(width: 30),
                                    Expanded(child: _buildField("Città", _indirizzoController, labelSize: labelFontSize, inputSize: inputFontSize)),
                                  ],
                                )
                              else ...[
                                _buildField("Telefono", _telefonoController, isPhone: true, labelSize: labelFontSize, inputSize: inputFontSize),
                                _buildField("Città", _indirizzoController, labelSize: labelFontSize, inputSize: inputFontSize),
                              ],

                              const SizedBox(height: 40),

                              // Pulsante salva modifiche
                              SizedBox(
                                width: double.infinity,
                                height: isWideScreen ? 70 : 50,
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
                                      : Text(
                                    "SALVA MODIFICHE",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: buttonFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Helper per i campi di input
  Widget _buildField(
      String label,
      TextEditingController controller, {
        bool isEmail = false,
        bool isPhone = false,
        bool isReadOnly = false,
        required double labelSize,
        required double inputSize,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etichetta del campo
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: labelSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: isReadOnly,
            // Tipo di tastiera per facilitare l'input
            keyboardType: isEmail
                ? TextInputType.emailAddress
                : (isPhone ? TextInputType.phone : TextInputType.text),
            style: TextStyle(
                color: isReadOnly ? Colors.white54 : Colors.white,
                fontSize: inputSize
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black12,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: inputSize * 0.8,
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