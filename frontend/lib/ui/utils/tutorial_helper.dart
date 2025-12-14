import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:frontend/ui/style/color_palette.dart';
// Import per la navigazione alle NOTIFICHE
import 'package:frontend/ui/screens/profile/gestione_notifiche_cittadino.dart';

class TutorialHelper {
  static void showTutorial({
    required BuildContext context,
    required bool isRescuer,
    required GlobalKey keyMap,
    required GlobalKey keyContacts,
    required GlobalKey keySos,
    GlobalKey? keyEmergencyInfo,
    List<GlobalKey>? navbarKeys,
    required VoidCallback onFinish,
  }) {
    final screenSize = MediaQuery.of(context).size;

    // Crea la lista dei target in base al ruolo
    List<TargetFocus> targets = isRescuer
        ? _createRescuerTargets(
            mainContext: context,
            screenSize: screenSize,
            keyMap: keyMap,
            keyEmergencyInfo: keyEmergencyInfo,
            navbarKeys: navbarKeys,
          )
        : _createCitizenTargets(
            mainContext: context,
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
    required BuildContext mainContext,
    required Size screenSize,
    required GlobalKey keyMap,
    required GlobalKey keyContacts,
    required GlobalKey keySos,
    GlobalKey? keyEmergencyInfo,
    List<GlobalKey>? navbarKeys,
  }) {
    List<TargetFocus> targets = [];

    // 1. Intro
    targets.add(
      _buildWelcomeTarget(
        screenSize,
        "Ciao, sono Neptie!\nSarò il tuo assistente. Ricorda: conoscere l'app può salvarti la vita!",
        "assets/cavalluccio.png",
      ),
    );

    // 2. Info Emergenza (se presente)
    if (keyEmergencyInfo != null) {
      targets.add(
        _buildTarget(
          identify: "emergency_info",
          keyTarget: keyEmergencyInfo,
          text: "Qui vedi i dettagli dell'emergenza più vicina a te.",
          imagePath: "assets/cavalluccio.png",
          alignText: ContentAlign.bottom,
          radius: 15,
        ),
      );
    }

    // 3. Mappa
    targets.add(
      _buildTarget(
        identify: "map",
        keyTarget: keyMap,
        text: "La mappa mostra le zone con emergenze attive in tempo reale.",
        imagePath: "assets/cavalluccio.png",
        alignText: ContentAlign.bottom,
      ),
    );

    // 4. Contatti
    targets.add(
      _buildTarget(
        identify: "contacts",
        keyTarget: keyContacts,
        text: "Qui vedi gli ultimi eventi e i tuoi contatti di emergenza.",
        imagePath: "assets/cavalluccio.png",
        alignText: ContentAlign.top,
      ),
    );

    // 5. SOS
    targets.add(
      _buildTarget(
        identify: "sos",
        keyTarget: keySos,
        text:
            "Il pulsante SOS è essenziale: se sei in pericolo, premilo subito!",
        imagePath: "assets/cavalluccio.png",
        alignText: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
      ),
    );

    // 6. Navbar Tabs (CITTADINO)
    if (navbarKeys != null) {
      if (navbarKeys.isNotEmpty) {
        targets.add(
          _buildTarget(
            identify: "nav_home",
            keyTarget: navbarKeys[0],
            text: "Cliccando qui, ritornerai sempre alla home.",
            imagePath: "assets/cavalluccio.png",
            alignText: ContentAlign.top,
            shape: ShapeLightFocus.Circle,
            radius: 25,
          ),
        );
      }
      if (navbarKeys.length > 1) {
        targets.add(
          _buildTarget(
            identify: "nav_report",
            keyTarget: navbarKeys[1],
            text: "Qui puoi creare una segnalazione specifica.",
            imagePath: "assets/cavalluccio.png",
            alignText: ContentAlign.top,
            shape: ShapeLightFocus.Circle,
            radius: 25,
          ),
        );
      }
      if (navbarKeys.length > 2) {
        targets.add(
          _buildTarget(
            identify: "nav_map",
            keyTarget: navbarKeys[2],
            text: "Mappa a schermo intero.",
            imagePath: "assets/cavalluccio.png",
            alignText: ContentAlign.top,
            shape: ShapeLightFocus.Circle,
            radius: 25,
          ),
        );
      }
      if (navbarKeys.length > 3) {
        targets.add(
          _buildTarget(
            identify: "nav_alerts",
            keyTarget: navbarKeys[3],
            text: "Lista completa delle emergenze attive.",
            imagePath: "assets/cavalluccio.png",
            alignText: ContentAlign.top,
            shape: ShapeLightFocus.Circle,
            radius: 25,
          ),
        );
      }
      if (navbarKeys.length > 4) {
        targets.add(
          _buildTarget(
            identify: "nav_settings",
            keyTarget: navbarKeys[4],
            text: "Qui trovi il tuo profilo e le impostazioni.",
            imagePath: "assets/cavalluccio.png",
            alignText: ContentAlign.top,
            shape: ShapeLightFocus.Circle,
            radius: 25,
          ),
        );
      }
    }

    //REINDIRIZZAMENTO AUTOMATICO (VERSO NOTIFICHE)
    targets.add(
      TargetFocus(
        identify: "notifications_redirect",
        keyTarget: (navbarKeys != null && navbarKeys.length > 4)
            ? navbarKeys[4]
            : keyMap,
        shape: ShapeLightFocus.Circle,
        radius: 30,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return AutoNavigator(
                parentContext: mainContext,
                nextScreen: const GestioneNotificheCittadino(),
                child: _buildContentBox(
                  "Adesso andiamo a configurare le notifiche.\nUn attimo solo...",
                  "assets/cavalluccio.png",
                ),
              );
            },
          ),
        ],
      ),
    );

    //SPIEGAZIONE SCHERMATA NOTIFICHE
    targets.add(
      _buildGenericScreenTarget(
        screenSize,
        "Eccoci!\nQui puoi attivare o disattivare:\n\n1. Notifiche Push (Avvisi immediati)\n2. SMS (In caso di assenza internet)\n3. Email (Riepiloghi)",
        "assets/cavalluccio.png",
      ),
    );

    // Outro
    targets.add(
      _buildWelcomeTarget(
        screenSize,
        "Tutto pronto! Configura le preferenze e poi premi 'Indietro' per tornare alla Home.",
        "assets/cavalluccio.png",
      ),
    );

    return targets;
  }

  static List<TargetFocus> _createRescuerTargets({
    required BuildContext mainContext,
    required Size screenSize,
    required GlobalKey keyMap,
    GlobalKey? keyEmergencyInfo,
    List<GlobalKey>? navbarKeys,
  }) {
    List<TargetFocus> targets = [];

    // 1. Intro
    targets.add(
      _buildWelcomeTarget(
        screenSize,
        "Ciao Collega!\nSono qui per aiutarti a gestire gli interventi.",
        "assets/cavalluccioSoccorritore.png",
      ),
    );

    // 2. Info Emergenza
    if (keyEmergencyInfo != null) {
      targets.add(
        _buildTarget(
          identify: "emergency_info",
          keyTarget: keyEmergencyInfo,
          text: "Qui vedi i dettagli dell'intervento assegnato.",
          imagePath: "assets/cavalluccioSoccorritore.png",
          alignText: ContentAlign.bottom,
          radius: 15,
        ),
      );
    }

    // 3. Mappa
    targets.add(
      TargetFocus(
        identify: "map",
        keyTarget: keyMap,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
            ),
            builder: (context, controller) {
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 180,
                      child: Image.asset("assets/cavalluccioSoccorritore.png"),
                    ),
                    const SizedBox(height: 20),
                    _buildContentBox(
                      "La mappa tattica mostra la tua posizione e il target.",
                      null,
                      customColor: const Color(0xFF1E3A5F),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    // 6. Navbar Tabs (SOCCORRITORE)
    if (navbarKeys != null) {
      if (navbarKeys.isNotEmpty) {
        targets.add(
          _buildTarget(
            identify: "nav_home",
            keyTarget: navbarKeys[0],
            text: "Torna alla dashboard operativa.",
            imagePath: "assets/cavalluccioSoccorritore.png",
            alignText: ContentAlign.top,
            shape: ShapeLightFocus.Circle,
            radius: 25,
          ),
        );
      }
      if (navbarKeys.length > 1) {
        targets.add(
          _buildTarget(
            identify: "nav_report",
            keyTarget: navbarKeys[1],
            text: "Segnala un'emergenza o aggiorna lo stato dell'intervento.",
            imagePath: "assets/cavalluccioSoccorritore.png",
            alignText: ContentAlign.top,
            shape: ShapeLightFocus.Circle,
            radius: 25,
          ),
        );
      }
      if (navbarKeys.length > 2) {
        targets.add(
          _buildTarget(
            identify: "nav_map",
            keyTarget: navbarKeys[2],
            text: "Mappa operativa a schermo intero.",
            imagePath: "assets/cavalluccioSoccorritore.png",
            alignText: ContentAlign.top,
            shape: ShapeLightFocus.Circle,
            radius: 25,
          ),
        );
      }
      if (navbarKeys.length > 3) {
        targets.add(
          _buildTarget(
            identify: "nav_alerts",
            keyTarget: navbarKeys[3],
            text: "Log delle notifiche operative e dispacci.",
            imagePath: "assets/cavalluccioSoccorritore.png",
            alignText: ContentAlign.top,
            shape: ShapeLightFocus.Circle,
            radius: 25,
          ),
        );
      }
      if (navbarKeys.length > 4) {
        targets.add(
          _buildTarget(
            identify: "nav_settings",
            keyTarget: navbarKeys[4],
            text: "Impostazioni del profilo di servizio.",
            imagePath: "assets/cavalluccioSoccorritore.png",
            alignText: ContentAlign.top,
            shape: ShapeLightFocus.Circle,
            radius: 25,
          ),
        );
      }
    }
    targets.add(
      TargetFocus(
        identify: "notifications_redirect",
        keyTarget: (navbarKeys != null && navbarKeys.length > 4)
            ? navbarKeys[4]
            : keyMap,
        shape: ShapeLightFocus.Circle,
        radius: 30,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (ctx, controller) {
              return AutoNavigator(
                parentContext: mainContext,
                nextScreen: const GestioneNotificheCittadino(),
                child: _buildContentBox(
                  "Verifichiamo i canali di allerta operativa. Ti porto alla configurazione...",
                  "assets/cavalluccioSoccorritore.png",
                ),
              );
            },
          ),
        ],
      ),
    );

    //SPIEGAZIONE NOTIFICHE (SOCCORRITORE)
    targets.add(
      _buildGenericScreenTarget(
        screenSize,
        "Collega, assicurati che PUSH ed SMS siano attivi per ricevere i dispacci in tempo reale!",
        "assets/cavalluccioSoccorritore.png",
      ),
    );

    // Outro
    targets.add(
      _buildWelcomeTarget(
        screenSize,
        "Buon lavoro! Configura tutto e premi 'Indietro' per iniziare il turno.",
        "assets/cavalluccioSoccorritore.png",
      ),
    );

    return targets;
  }

  static TargetFocus _buildWelcomeTarget(
    Size screenSize,
    String text,
    String imagePath,
  ) {
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
                  _buildContentBox(
                    text,
                    null,
                    customColor: const Color(0xFF1E3A5F),
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
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: alignText,
          builder: (context, controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [_buildContentBox(text, imagePath)],
            );
          },
        ),
      ],
    );
  }

  static TargetFocus _buildGenericScreenTarget(
    Size screenSize,
    String text,
    String imagePath,
  ) {
    return TargetFocus(
      identify: "generic_screen_info",
      targetPosition: TargetPosition(
        const Size(0, 0),
        Offset(screenSize.width / 2, screenSize.height / 3),
      ),
      shape: ShapeLightFocus.Circle,
      radius: 0,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 150, child: Image.asset(imagePath)),
                const SizedBox(height: 20),
                _buildContentBox(text, null, showTriangle: false),
              ],
            );
          },
        ),
      ],
    );
  }

  static Widget _buildContentBox(
    String text,
    String? imagePath, {
    bool showTriangle = true,
    Color? customColor,
  }) {
    final bgColor = customColor ?? ColorPalette.backgroundDeepBlue;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
            border: Border.all(color: Colors.white30),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (showTriangle)
          CustomPaint(
            painter: TrianglePainter(
              strokeColor: bgColor,
              paintingStyle: PaintingStyle.fill,
            ),
            child: const SizedBox(height: 10, width: 20),
          ),
        if (imagePath != null)
          SizedBox(height: 100, child: Image.asset(imagePath)),
      ],
    );
  }
}

class AutoNavigator extends StatefulWidget {
  final Widget child;
  final BuildContext parentContext;
  final Widget nextScreen;

  const AutoNavigator({
    super.key,
    required this.child,
    required this.parentContext,
    required this.nextScreen,
  });

  @override
  State<AutoNavigator> createState() => _AutoNavigatorState();
}

class _AutoNavigatorState extends State<AutoNavigator> {
  @override
  void initState() {
    super.initState();
    // Navigazione automatica dopo breve ritardo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => widget.nextScreen));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  TrianglePainter({
    this.strokeColor = Colors.black,
    this.strokeWidth = 3,
    this.paintingStyle = PaintingStyle.stroke,
  });
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
