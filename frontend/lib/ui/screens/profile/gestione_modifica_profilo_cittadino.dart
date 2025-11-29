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

  final ProfileRepository _profileRepository = ProfileRepository();

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
        telefono: _telefonoController.text.trim(),
        email: _emailController.text.trim(),
        citta: _indirizzoController.text.trim(),
      );

      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).updateUserLocally(
          nome: _nomeController.text.trim(),
          cognome: _cognomeController.text.trim(),
          telefono: _telefonoController.text.trim(),
        );
        await Provider.of<AuthProvider>(context, listen: false).reloadUser();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profilo aggiornato con successo!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
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
    // Logica responsive
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 700;

    final isRescuer = context.watch<AuthProvider>().isRescuer;

    Color bgColor = isRescuer ? const Color(0xFFEF923D) : const Color(0xFF12345A);
    Color cardColor = isRescuer ? const Color(0xFFD65D01): const Color(0xFF0E2A48);
    Color accentColor = isRescuer ? const Color(0xFF12345A) : const Color(0xFFEF923D);
    const Color iconColor = Color(0xFFE3C63D);

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

                // Header
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

                // 2. Contenuto centrato
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

                              _buildField("Email", _emailController, isEmail: true, labelSize: labelFontSize, inputSize: inputFontSize),

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