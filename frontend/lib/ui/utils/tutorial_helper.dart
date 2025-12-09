import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:frontend/ui/style/color_palette.dart';

class TutorialHelper {
  static void showTutorial({
    required BuildContext context,
    required bool isRescuer,
    required GlobalKey keyMap,
    required GlobalKey keyContacts,
    required GlobalKey keySos,
    GlobalKey? keyEmergencyInfo,
    List<GlobalKey>? navbarKeys,    // Lista chiavi per i singoli tab della navbar
    required VoidCallback onFinish,
  }) {
    final screenSize = MediaQuery.of(context).size;

    // Decide quale lista target (la serie di step del tutorial) creare
    List<TargetFocus> targets = isRescuer
        ? _createRescuerTargets(
      screenSize: screenSize,
      keyMap: keyMap,
      keyEmergencyInfo: keyEmergencyInfo,
      navbarKeys: navbarKeys,
    )
        : _createCitizenTargets(
      screenSize: screenSize,
      keyMap: keyMap,
      keyContacts: keyContacts,
      keySos: keySos,
      keyEmergencyInfo: keyEmergencyInfo,
      navbarKeys: navbarKeys,
    );

    TutorialCoachMark(
      targets: targets,
      hideSkip: true,
      colorShadow: Colors.black,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: onFinish,
      onSkip: () {
        onFinish();
        return true;
      },
    ).show(context: context);
  }

  // Lista target cittadino
  static List<TargetFocus> _createCitizenTargets({
    required Size screenSize,
    required GlobalKey keyMap,
    required GlobalKey keyContacts,
    required GlobalKey keySos,
    GlobalKey? keyEmergencyInfo,
    List<GlobalKey>? navbarKeys,
  }) {
    List<TargetFocus> targets = [];

    // 1. Benvenuto
    targets.add(_buildWelcomeTarget(screenSize,
        "Ciao, sono Neptie!\nSarò il tuo assistente. Ricorda: conoscere l'app può salvarti la vita!",
        "assets/cavalluccio.png"
    ));

    // 2. Info Emergenza Attiva
    if (keyEmergencyInfo != null) {
      targets.add(_buildTarget(
        identify: "emergency_info",
        keyTarget: keyEmergencyInfo,
        text: "Qui vedi i dettagli dell'emergenza più vicina a te, inclusi tipo, dati e distanza",
        imagePath: "assets/cavalluccio.png",
        alignText: ContentAlign.bottom,
        radius: 15,
      ));
    }

    // 3. Mappa
    targets.add(_buildTarget(
      identify: "map",
      keyTarget: keyMap,
      text: "La mappa mostra le zone con emergenze attive in tempo reale.",
      imagePath: "assets/cavalluccio.png",
      alignText: ContentAlign.bottom,
    ));

    // 4. Contatti
    targets.add(_buildTarget(
      identify: "contacts",
      keyTarget: keyContacts,
      text: "Qui vedi gli ultimi eventi e i tuoi contatti di emergenza.",
      imagePath: "assets/cavalluccio.png",
      alignText: ContentAlign.top,
    ));

    // 5. SOS
    targets.add(_buildTarget(
      identify: "sos",
      keyTarget: keySos,
      text: "Il pulsante SOS è essenziale: se sei in pericolo, premilo subito!",
      imagePath: "assets/cavalluccio.png",
      alignText: ContentAlign.top,
      shape: ShapeLightFocus.Circle,
    ));

    // 6. Tab Home (Indice 0)
    if (navbarKeys != null && navbarKeys.isNotEmpty) {
      targets.add(_buildTarget(
        identify: "nav_home",
        keyTarget: navbarKeys[0],
        text: "Cliccando qui, ritornerai alla schermata home, quella dove stiamo ora",
        imagePath: "assets/cavalluccio.png",
        alignText: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
        radius: 30,
      ));
    }

    // 7. Tab Report (Indice 1)
    if (navbarKeys != null && navbarKeys.length > 1) {
      targets.add(_buildTarget(
        identify: "nav_report",
        keyTarget: navbarKeys[1],
        text: "Qui puoi creare una sagnalazione specifica scegliendone posizione, tipologia, eventuale descrizione e spuntando la casellina se hai bisogno d'aiuto!",
        imagePath: "assets/cavalluccio.png",
        alignText: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
        radius: 30,
      ));
    }

    // 8. Tab Mappa (Indice 2)
    if (navbarKeys != null && navbarKeys.length > 2) {
      targets.add(_buildTarget(
        identify: "nav_map",
        keyTarget: navbarKeys[2],
        text: "Da qui puoi accedere alla mappa a schermo intero",
        imagePath: "assets/cavalluccio.png",
        alignText: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
        radius: 30,
      ));
    }

    // 9. Tab Avvisi (Indice 3)
    if (navbarKeys != null && navbarKeys.length > 3) {
      targets.add(_buildTarget(
        identify: "nav_alerts",
        keyTarget: navbarKeys[3],
        text: "Controlla qui le notifiche sulle emergenze attive, così da non perderne mai una",
        imagePath: "assets/cavalluccio.png",
        alignText: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
        radius: 30,
      ));
    }

    // 10. Tab Impostazioni (Indice 4)
    if (navbarKeys != null && navbarKeys.length > 4) {
      targets.add(_buildTarget(
        identify: "nav_settings",
        keyTarget: navbarKeys[4],
        text: "Questo è un collegamento per la pagina delle impostazioni del profilo",
        imagePath: "assets/cavalluccio.png",
        alignText: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
        radius: 30,
      ));
    }

    // 11. Outro Utente
    targets.add(_buildWelcomeTarget(screenSize,
        "Detto ciò, buona giornata e ricorda: siamo sempre a tua disposizione! Come dice il nostro motto: uniti nell'emergenza, più sicuri insieme!",
        "assets/cavalluccio.png"
    ));

    return targets;
  }

  // Lista target soccorritore
  static List<TargetFocus> _createRescuerTargets({
    required Size screenSize,
    required GlobalKey keyMap,
    GlobalKey? keyEmergencyInfo,
    List<GlobalKey>? navbarKeys,
  }) {
    List<TargetFocus> targets = [];

    // 1. Intro Soccorritore
    targets.add(_buildWelcomeTarget(screenSize,
        "Ciao Collega!\nSono qui per aiutarti a gestire gli interventi in modo rapido ed efficiente.",
        "assets/cavalluccioSoccorritore.png"
    ));

    // 2. Info Emergenza Attiva
    if (keyEmergencyInfo != null) {
      targets.add(_buildTarget(
        identify: "emergency_info",
        keyTarget: keyEmergencyInfo,
        text: "Qui vedi i dettagli dell'intervento assegnato: tipo, indirizzo e distanza.",
        imagePath: "assets/cavalluccioSoccorritore.png",
        alignText: ContentAlign.bottom,
        radius: 15,
      ));
    }

// Metodo helper per centrare il cavalluccio nella mappa nel tutorial lato soccorritore
    TargetFocus buildMapTarget({
      required GlobalKey keyTarget,
      required Size screenSize,
      required String text,
      required String imagePath,
    }) {
      return TargetFocus(
        identify: "map",
        keyTarget: keyTarget,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            // Qui si usa custom per sganciare il focus dalla mappa e piazzare
            // il cavalluccio a centro schermo, altrimenti uscirebbe fuori
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0
            ),
            builder: (context, controller) {
              return Container(
                width: screenSize.width,
                height: screenSize.height,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cavalluccio
                    SizedBox(
                        height: 180,
                        child: Image.asset(imagePath)
                    ),
                    const SizedBox(height: 20),
                    // Testo
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A5F),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black45)],
                      ),
                      child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    }

    // 3. Mappa
    targets.add(buildMapTarget(
      keyTarget: keyMap,
      screenSize: screenSize,
      text: "La mappa mostra la tua posizione, il target e i colleghi vicini.",
      imagePath: "assets/cavalluccioSoccorritore.png",
    ));

    // 4. Tab Home (Indice 0)
    if (navbarKeys != null && navbarKeys.isNotEmpty) {
      targets.add(_buildTarget(
        identify: "nav_home",
        keyTarget: navbarKeys[0],
        text: "Cliccando qui, ritornerai alla schermata home, quella dove stiamo ora",
        imagePath: "assets/cavalluccioSoccorritore.png",
        alignText: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
        radius: 30,
      ));
    }

    // 5. Tab Report (Indice 1)
    if (navbarKeys != null && navbarKeys.length > 1) {
      targets.add(_buildTarget(
        identify: "nav_report",
        keyTarget: navbarKeys[1],
        text: "Qui puoi creare una sagnalazione specifica scegliendone posizione, tipologia e eventuale descrizione",
        imagePath: "assets/cavalluccioSoccorritore.png",
        alignText: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
        radius: 30,
      ));
    }

    // 6. Tab Mappa (Indice 2)
    if (navbarKeys != null && navbarKeys.length > 2) {
      targets.add(_buildTarget(
        identify: "nav_map",
        keyTarget: navbarKeys[2],
        text: "Da qui puoi accedere alla mappa a schermo intero",
        imagePath: "assets/cavalluccioSoccorritore.png",
        alignText: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
        radius: 30,
      ));
    }

    // 7. Tab Avvisi (Indice 3)
    if (navbarKeys != null && navbarKeys.length > 3) {
      targets.add(_buildTarget(
        identify: "nav_alerts",
        keyTarget: navbarKeys[3],
        text: "Controlla qui le notifiche sulle emergenze attive, così da non perderne mai una",
        imagePath: "assets/cavalluccioSoccorritore.png",
        alignText: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
        radius: 30,
      ));
    }

    // 8. Tab Impostazioni (Indice 4)
    if (navbarKeys != null && navbarKeys.length > 4) {
      targets.add(_buildTarget(
        identify: "nav_settings",
        keyTarget: navbarKeys[4],
        text: "Questo è un collegamento per la pagina delle impostazioni del profilo",
        imagePath: "assets/cavalluccioSoccorritore.png",
        alignText: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
        radius: 30,
      ));
    }

    // 9. Outro Soccorritore
    targets.add(_buildWelcomeTarget(screenSize,
        "Detto ciò, buon lavoro e ricorda: contiamo su di te! Come dice il nostro motto: uniti nell'emergenza, più sicuri insieme!",
        "assets/cavalluccioSoccorritore.png"
    ));

    return targets;
  }

  // Metodo per intro e outro
  static TargetFocus _buildWelcomeTarget(Size screenSize, String text, String imagePath) {
    return TargetFocus(
      identify: "intro",
      targetPosition: TargetPosition(const Size(0, 0), const Offset(0, 0)),
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return Container(
              height: screenSize.height - 100,
              width: screenSize.width,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 200, child: Image.asset(imagePath)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
                    ),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  //Metodo per centrare il focus sull'elemento attuale
  static TargetFocus _buildTarget({
    required String identify,
    required GlobalKey keyTarget,
    required String text,
    required String imagePath,
    ContentAlign alignText = ContentAlign.bottom,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
    double radius = 10.0,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: keyTarget,
      shape: shape,
      radius: radius,
      contents: [
        TargetContent(
          align: alignText,
          builder: (context, controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorPalette.backgroundDeepBlue,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
                  ),
                  child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                CustomPaint(
                  painter: TrianglePainter(strokeColor: ColorPalette.backgroundDeepBlue, paintingStyle: PaintingStyle.fill),
                  child: const SizedBox(height: 10, width: 20),
                ),
                SizedBox(height: 150, child: Image.asset(imagePath)),
              ],
            );
          },
        ),
      ],
    );
  }
}

// Painter per fare la punta della nuvoletta
class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  TrianglePainter({this.strokeColor = Colors.black, this.strokeWidth = 3, this.paintingStyle = PaintingStyle.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(x, 0)
      ..lineTo(x / 2, y)
      ..lineTo(0, 0);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => true;
}