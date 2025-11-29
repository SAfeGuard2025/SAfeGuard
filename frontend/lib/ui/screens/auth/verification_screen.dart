import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/ui/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';

import '../../widgets/bubble_background.dart';

// Schermata di Verifica OTP
// Permette all'utente di inserire il codice OTP ricevuto per completare la registrazione/accesso.
class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  static const Color darkBluePrimary = ColorPalette.backgroundMidBlue;
  static const Color darkBlueButton = ColorPalette.verificationButtonBlue;
  static const Color textWhite = Colors.white;

  // Controller e FocusNode
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _codeFocusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    // Rilascia le risorse dei controller e focus node
    for (var c in _codeControllers) {
      c.dispose();
    }
    for (var f in _codeFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // Unisce i 6 numeri inseriti in una stringa unica per l'invio al backend
  String _getVerificationCode() => _codeControllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    // Variabili per la responsività
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final double referenceSize = screenHeight < screenWidth
        ? screenHeight
        : screenWidth;
    final double titleFontSize = referenceSize * 0.075;
    final double subtitleFontSize = referenceSize * 0.04;
    final double inputCodeFontSize = referenceSize * 0.06;
    final double buttonFontSize = referenceSize * 0.05;

    final double verticalSpacing = screenHeight * 0.02;
    final double largeSpacing = screenHeight * 0.04;
    final double buttonHeight = referenceSize * 0.12;

    // Ascolto dell'AuthProvider per stato, errori e timer
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      // 1. BLOCCA IL RIDIMENSIONAMENTO DELLO SFONDO
      resizeToAvoidBottomInset: false,
      backgroundColor: darkBluePrimary,

      body: Stack(
        // 2. FORZA LO STACK A RIEMPIRE LO SCHERMO
        fit: StackFit.expand,
        children: [
          // 3. SFONDO CON BOLLE TYPE 3 (Fisso)
          const Positioned.fill(
            child: BubbleBackground(type: BubbleType.type3),
          ),

          // Contenuto Scrollabile
          SafeArea(
            // LayoutBuilder ci dà l'altezza totale disponibile dello schermo
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  // Gestione padding tastiera
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  // ConstrainedBox + IntrinsicHeight servono per far funzionare lo Spacer()
                  // all'interno di una SingleChildScrollView
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: verticalSpacing / 2),

                          // Tasto Indietro
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),

                          SizedBox(height: verticalSpacing),

                          // Titoli
                          Text(
                            "Codice di verifica",
                            style: TextStyle(
                              color: textWhite,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: verticalSpacing),
                          Text(
                            "Abbiamo inviato un codice OTP.\nInseriscilo per verificare la tua identità.",
                            style: TextStyle(
                              color: textWhite,
                              fontSize: subtitleFontSize,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: largeSpacing),

                          // Griglia di input (6 Cifre)
                          _buildVerificationCodeInput(
                            context,
                            inputCodeFontSize,
                          ),

                          // Messaggio di errore dal Provider
                          if (authProvider.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Center(
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                          // Spacer: spinge il contenuto successivo in fondo
                          const Spacer(),

                          // Bottone verifica
                          SizedBox(
                            width: double.infinity,
                            height: buttonHeight,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () async {
                                      final code = _getVerificationCode();
                                      // Validazione lato client: codice completo a 6 cifre
                                      if (code.length < 6) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Inserisci il codice completo a 6 cifre",
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      final navigator = Navigator.of(context);
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );

                                      // Chiamata al Provider per la verifica
                                      bool success = await authProvider
                                          .verifyCode(code);

                                      if (success && context.mounted) {
                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text("Verifica riuscita!"),
                                          ),
                                        );
                                        // Naviga alla schermata di Login/Home e rimuove tutte le schermate precedenti
                                        navigator.pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            // Dopo la verifica, l'utente accede o torna al Login
                                            builder: (context) =>
                                                const LoginScreen(),
                                          ),
                                          (route) => false,
                                        );
                                      }
                                    },

                              // Stile del bottone
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkBlueButton,
                                foregroundColor: textWhite,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                              ),

                              // Contenuto del bottone
                              child: authProvider.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "VERIFICA",
                                      style: TextStyle(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                            ),
                          ),

                          SizedBox(height: verticalSpacing),

                          // Timer rinvio codice
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  "Non hai ricevuto il codice?",
                                  style: TextStyle(
                                    color: textWhite,
                                    fontSize: subtitleFontSize * 0.8,
                                  ),
                                ),
                                SizedBox(height: verticalSpacing / 4),
                                GestureDetector(
                                  onTap: () {
                                    // Permetti il rinvio solo se il timer è a zero
                                    if (authProvider.secondsRemaining == 0) {
                                      authProvider
                                          .resendOtp(); // Usato resendOtp del provider
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Nuovo codice inviato!",
                                          ),
                                        ),
                                      );
                                      // Resetta i campi e il focus
                                      for (var c in _codeControllers) {
                                        c.clear();
                                      }
                                      _codeFocusNodes[0].requestFocus();
                                    }
                                  },
                                  child: Text(
                                    authProvider.secondsRemaining == 0
                                        ? "Invia di nuovo il codice"
                                        : "Rinvia il codice in (0:${authProvider.secondsRemaining.toString().padLeft(2, '0')})",
                                    style: TextStyle(
                                      // Colore condizionale in base al timer
                                      color: authProvider.secondsRemaining == 0
                                          ? textWhite
                                          : textWhite.withValues(alpha: 0.5),
                                      fontSize: subtitleFontSize * 0.8,
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.underline,
                                      decorationColor:
                                          authProvider.secondsRemaining == 0
                                          ? textWhite
                                          : textWhite.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                                SizedBox(height: verticalSpacing / 4),
                              ],
                            ),
                          ),
                          SizedBox(height: verticalSpacing / 2),
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
    );
  }

  // Widget Helper per la Griglia di input del Codice OTP
  Widget _buildVerificationCodeInput(
    BuildContext context,
    double inputCodeFontSize,
  ) {
    return Column(
      children: [
        // Prima riga
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (index) => _buildCodeBox(index, context, inputCodeFontSize),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        // Seconda riga
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (index) => _buildCodeBox(index + 3, context, inputCodeFontSize),
          ),
        ),
      ],
    );
  }

  // Widget Helper per la singola Casella di input
  Widget _buildCodeBox(
    int index,
    BuildContext context,
    double inputCodeFontSize,
  ) {
    // Calcola la dimensione della casella per adattarsi allo schermo
    final boxSize = (MediaQuery.of(context).size.width - 40) / 7;

    // Usa KeyboardListener per gestire in modo esplicito il tasto Backspace
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.backspace) {
            // Se la casella è vuota e viene premuto backspace, sposta il focus alla casella precedente
            if (_codeControllers[index].text.isEmpty && index > 0) {
              // Cancella il contenuto della casella precedente per consistenza
              _codeFocusNodes[index - 1].requestFocus();
            }
          }
        }
      },
      child: SizedBox(
        width: boxSize,
        height: boxSize,
        child: Container(
          decoration: BoxDecoration(
            color: textWhite.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: TextField(
              controller: _codeControllers[index],
              focusNode: _codeFocusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,

              // Limita l'input ad una sola cifra e solo a numeri
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],

              style: TextStyle(
                fontSize: inputCodeFontSize,
                fontWeight: FontWeight.bold,
                color: darkBluePrimary,
              ),
              decoration: const InputDecoration(
                counterText: "",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),

              onChanged: (value) {
                // Logica per spostare il focus automaticamente
                if (value.length == 1) {
                  // Se viene inserita una cifra, sposta il focus in avanti
                  if (index < 5) {
                    FocusScope.of(
                      context,
                    ).requestFocus(_codeFocusNodes[index + 1]);
                  } else {
                    FocusScope.of(
                      context,
                    ).unfocus(); // Se è l'ultima casella, nasconde la tastiera
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
