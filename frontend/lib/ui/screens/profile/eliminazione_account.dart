import 'package:frontend/ui/style/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class DeleteProfilePage extends StatelessWidget {
  const DeleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Variabili per responsiveness
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 700;

    // Dimensioni testo e icone
    final double titleSize = isWideScreen ? 40 : 28;
    final double buttonFontSize = isWideScreen ? 32 : 22;
    // Icona header
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

            // 2. CORPO CENTRALE (Scrollabile ma centrato visivamente)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      // Forza il contenuto ad occupare almeno l'altezza disponibile
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.08,
                          vertical: 20, // Padding verticale minimo
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // Centra verticalmente
                          children: [
                            // BOX DI AVVERTIMENTO (Più grande e in evidenza)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical:
                                    40, // Aumentato per renderlo più grande
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: isRescuer
                                    ? ColorPalette.cardDarkOrange
                                    : ColorPalette.primaryDarkButtonBlue,
                                borderRadius: BorderRadius.circular(
                                  24,
                                ), // Più rotondo
                                border: Border.all(
                                  color: Colors.white.withOpacity(
                                    0.3,
                                  ), // Bordo leggero
                                  width: 2,
                                ),
                                boxShadow: [
                                  // Ombra per staccarlo dallo sfondo (Evidenza)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Icona di Alert per evidenza
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: ColorPalette
                                        .iconAccentYellow, // O Colors.amber
                                    size: 50,
                                  ),
                                  const SizedBox(height: 15),

                                  const Text(
                                    "Sei assolutamente sicuro?",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.w900, // Più grassetto
                                      fontSize: 26, // Testo un po' più grande
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
                                      color: Colors
                                          .white70, // Leggermente più leggibile
                                      fontSize: 19,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 50,
                            ), // Spazio aumentato tra box e bottone
                            // BOTTONE ELIMINA
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Account eliminato"),
                                    ),
                                  );
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ), // Bottone più alto
                                  backgroundColor:
                                      ColorPalette.emergencyButtonRed,
                                  foregroundColor: Colors.white,
                                  elevation: 8, // Ombra bottone
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  "Elimina Profilo",
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
