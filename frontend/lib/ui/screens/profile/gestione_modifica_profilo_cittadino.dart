import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/repositories/profile_repository.dart';
import 'package:data_models/utente_generico.dart';
import 'package:frontend/ui/style/color_palette.dart';
import 'package:frontend/ui/screens/profile/eliminazione_account.dart';

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
    _indirizzoController = TextEditingController(
      text: user?.cittaDiNascita ?? "",
    );
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
        const SnackBar(
          content: Text("Profilo aggiornato con successo!"),
          backgroundColor: Colors.green,
        ),
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
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 700;
    final isRescuer = context.watch<AuthProvider>().isRescuer;

    // Colori
    Color bgColor = isRescuer
        ? ColorPalette.primaryOrange
        : ColorPalette.backgroundMidBlue;
    Color cardColor = isRescuer
        ? ColorPalette.cardDarkOrange
        : ColorPalette.backgroundDarkBlue;
    Color accentColor = isRescuer
        ? ColorPalette.backgroundMidBlue
        : ColorPalette.primaryOrange;
    const Color iconColor = ColorPalette.iconAccentYellow;
    Color deleteButtonColor = ColorPalette.emergencyButtonRed;

    // Font Sizes
    final double titleSize = isWideScreen ? 50 : 28;
    final double iconSize = isWideScreen ? 60 : 40;
    final double labelFontSize = isWideScreen ? 24 : 14;
    final double inputFontSize = isWideScreen ? 26 : 16;
    final double buttonFontSize = isWideScreen ? 28 : 18;

    return Scaffold(
      backgroundColor: bgColor,
      // ResizeToAvoidBottomInset true permette alla tastiera di spingere il contenuto
      // ma con la nostra struttura fissa, gestiamo meglio gli spazi
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                // 1. HEADER (Fisso in alto)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
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

                // 2. CORPO SCORREVOLE (Contiene la "Zona" campi e la Danger Zone)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        // --- ZONA INPUT (Tipo Slider/Card) ---
                        Container(
                          padding: EdgeInsets.all(isWideScreen ? 40.0 : 20.0),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(25.0),
                            // Ombra per dare l'effetto sollevato "slider"
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Campi Nome e Cognome
                              if (isWideScreen)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildField(
                                        "Nome",
                                        _nomeController,
                                        labelSize: labelFontSize,
                                        inputSize: inputFontSize,
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    Expanded(
                                      child: _buildField(
                                        "Cognome",
                                        _cognomeController,
                                        labelSize: labelFontSize,
                                        inputSize: inputFontSize,
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                _buildField(
                                  "Nome",
                                  _nomeController,
                                  labelSize: labelFontSize,
                                  inputSize: inputFontSize,
                                ),
                                _buildField(
                                  "Cognome",
                                  _cognomeController,
                                  labelSize: labelFontSize,
                                  inputSize: inputFontSize,
                                ),
                              ],

                              // Campo Email
                              _buildField(
                                "Email",
                                _emailController,
                                isEmail: true,
                                labelSize: labelFontSize,
                                inputSize: inputFontSize,
                              ),

                              // Campi Telefono e Città
                              if (isWideScreen)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildField(
                                        "Telefono",
                                        _telefonoController,
                                        isPhone: true,
                                        labelSize: labelFontSize,
                                        inputSize: inputFontSize,
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    Expanded(
                                      child: _buildField(
                                        "Città",
                                        _indirizzoController,
                                        labelSize: labelFontSize,
                                        inputSize: inputFontSize,
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                _buildField(
                                  "Telefono",
                                  _telefonoController,
                                  isPhone: true,
                                  labelSize: labelFontSize,
                                  inputSize: inputFontSize,
                                ),
                                _buildField(
                                  "Città",
                                  _indirizzoController,
                                  labelSize: labelFontSize,
                                  inputSize: inputFontSize,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // --- DANGER ZONE (Separata dalla card principale) ---
                        // --- DANGER ZONE (Stile Card uniformato) ---
                        Container(
                          padding: EdgeInsets.all(isWideScreen ? 30.0 : 20.0),
                          decoration: BoxDecoration(
                            // Sfondo solido rossastro ma scuro, simile alla card principale per "peso" visivo
                            color: deleteButtonColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(25.0),
                            border: Border.all(
                              color: deleteButtonColor,
                              width: 2,
                            ),
                            // Stessa ombra della card dati per coerenza stilistica
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.white,
                                    size: labelFontSize * 1.5,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Zona Pericolosa",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          labelFontSize *
                                          1.2, // Titolo più grande
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "L'eliminazione dell'account è definitiva e irreversibile.",
                                      style: TextStyle(
                                        color: Colors
                                            .white, // Colore bianco pieno per massima leggibilità
                                        fontSize:
                                            labelFontSize, // Font size normale, non ridotto
                                        fontWeight: FontWeight.w500,
                                        height:
                                            1.4, // Interlinea per migliorare la lettura
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: deleteButtonColor,
                                      foregroundColor: Colors.white,
                                      elevation: 4,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const DeleteProfilePage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "ELIMINA",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: labelFontSize,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Spazio extra per evitare che l'ultimo elemento sia coperto dal bottone fisso
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // 3. BOTTOM BAR (Pulsante SALVA FUORI dalla zona)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bgColor, // Si fonde con lo sfondo
                  ),
                  child: SizedBox(
                    height: isWideScreen ? 70 : 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
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
              fontSize: inputSize,
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
