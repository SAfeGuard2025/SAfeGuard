import 'package:frontend/ui/style/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/screens/auth/login_screen.dart';

class DeleteProfilePage extends StatefulWidget {
  const DeleteProfilePage({super.key});

  @override
  State<DeleteProfilePage> createState() => _DeleteProfilePageState();
}

class _DeleteProfilePageState extends State<DeleteProfilePage> {
  // Stato per gestire lo spinner di caricamento
  bool _isLoading = false;

  void _handleDelete() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Chiamata al backend per deleteAccount e logout
      await Provider.of<AuthProvider>(context, listen: false).deleteAccount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account eliminato correttamente.")),
        );
        // Reindirizzamento al Login e rimozione dello storico
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Errore durante l'eliminazione: $e"),
            backgroundColor: ColorPalette.emergencyButtonRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Variabili per responsiveness
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 700;

    // Dimensioni testo e icone
    final double titleSize = isWideScreen ? 40 : 28;
    final double buttonFontSize = isWideScreen ? 32 : 22;
    final double headerIconSize = isWideScreen ? 36 : 28;
    final Color headerIconColor = ColorPalette.iconAccentYellow;

    // Variabile per tema colori
    final isRescuer = context.watch<AuthProvider>().isRescuer;

    return Scaffold(
      backgroundColor: isRescuer
          ? ColorPalette.primaryOrange
          : ColorPalette.backgroundMidBlue,
      body: SafeArea(
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
                      size: headerIconSize,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.person_outlined,
                    color: headerIconColor,
                    size: headerIconSize + 8,
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "Elimina Profilo",
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

            // 2. CORPO CENTRALE
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.08,
                          vertical: 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // BOX DI AVVERTIMENTO
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 40,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: isRescuer
                                    ? ColorPalette.cardDarkOrange
                                    : ColorPalette.primaryDarkButtonBlue,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: ColorPalette.iconAccentYellow,
                                    size: 50,
                                  ),
                                  const SizedBox(height: 15),
                                  const Text(
                                    "Sei assolutamente sicuro?",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 26,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 25),
                                  const Text(
                                    "Questa azione è irreversibile.\n"
                                    "Eliminerà permanentemente il tuo account "
                                    "e tutti i dati associati, "
                                    "incluse le tue informazioni sanitarie.\n\n"
                                    "Eliminare l’account non ti esenterà "
                                    "da eventuali pene legate a segnalazioni false.",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 19,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 50),

                            // BOTTONE ELIMINA
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleDelete,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  backgroundColor:
                                  ColorPalette.emergencyButtonRed,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: ColorPalette
                                      .emergencyButtonRed
                                      .withValues(alpha: 0.6),
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                                    : Text(
                                  "Elimina Profilo",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: buttonFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20), // Spazio tra i bottoni

                            // BOTTONE ANNULLA (Nuovo)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                // Disabilita anche questo se sta caricando
                                onPressed: _isLoading
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  side: const BorderSide(
                                      color: Colors.white,
                                      width: 2.5
                                  ), // Bordo bianco
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  // Colore di sfondo al tocco
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(
                                  "Annulla",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: buttonFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            // Spazio extra in fondo per scorrimento sicuro
                            const SizedBox(height: 40),

                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
