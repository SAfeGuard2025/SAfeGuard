import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/ui/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';

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
    for (var c in _codeControllers) {
      c.dispose();
    }
    for (var f in _codeFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // Unisce i 6 numeri in una stringa unica
  String _getVerificationCode() => _codeControllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    // Variabili per la responsività
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final double referenceSize = screenHeight < screenWidth ? screenHeight : screenWidth;
    final double titleFontSize = referenceSize * 0.075;
    final double subtitleFontSize = referenceSize * 0.04;
    final double inputCodeFontSize = referenceSize * 0.06;
    final double buttonFontSize = referenceSize * 0.05;

    final double verticalSpacing = screenHeight * 0.02;
    final double largeSpacing = screenHeight * 0.04;
    final double buttonHeight = referenceSize * 0.12;


    final authProvider = Provider.of<AuthProvider>(context);
    final double viewHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: darkBluePrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [darkBluePrimary, ColorPalette.gradientDeepBlue],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            // Usato il viewHeight per garantire che lo scroll sia corretto anche con la tastiera
            child: SizedBox(
              height: viewHeight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: verticalSpacing / 2),
                    // Tasto Indietro
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
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
                      style: TextStyle(color: textWhite, fontSize: subtitleFontSize, height: 1.5),
                    ),
                    SizedBox(height: largeSpacing),

                    // Griglia di input (6 Cifre)
                    _buildVerificationCodeInput(context, inputCodeFontSize),

                    // Messaggio di Errore dal Provider (se il codice server è errato)
                    if (authProvider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Center(
                          child: Text(
                            authProvider.errorMessage!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

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
                          if (code.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Inserisci il codice completo a 6 cifre"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);

                          // Chiamata al Provider -> Server
                          bool success = await authProvider.verifyCode(code);

                          if (success && context.mounted) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text("Verifica riuscita!")),
                            );
                            navigator.pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                                  (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBlueButton,
                          foregroundColor: textWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
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
                            style: TextStyle(color: textWhite, fontSize: subtitleFontSize * 0.8),
                          ),
                          SizedBox(height: verticalSpacing / 4),
                          GestureDetector(
                            onTap: () {
                              if (authProvider.secondsRemaining == 0) {
                                authProvider.resendOtp(); // Usato resendOtp dal provider
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Nuovo codice inviato!")),
                                );
                                // Resetta i campi
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
                                color: authProvider.secondsRemaining == 0
                                    ? textWhite
                                    : textWhite.withValues(alpha: 0.5),
                                fontSize: subtitleFontSize * 0.8,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline,
                                decorationColor: authProvider.secondsRemaining == 0
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
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationCodeInput(BuildContext context, double inputCodeFontSize) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) => _buildCodeBox(index, context, inputCodeFontSize)),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) => _buildCodeBox(index + 3, context, inputCodeFontSize)),
        ),
      ],
    );
  }

  Widget _buildCodeBox(int index, BuildContext context, double inputCodeFontSize) {
    final boxSize = (MediaQuery.of(context).size.width - 40) / 7;

    // Keyboard listener per intercettare il backspace
    return KeyboardListener(
      focusNode: FocusNode(), // Nodo fittizio per il listener
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.backspace) {
            // Se voglio cancellare un numero lo cancello e vado alla "casella" dell'otp precedente
            if (_codeControllers[index].text.isEmpty && index > 0) {
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
                if (value.length == 1) {
                  // Ogni volta che inserisco un numero all'otp, vado avanti passando il focus alla casella successiva
                  if (index < 5) {
                    FocusScope.of(context).requestFocus(_codeFocusNodes[index + 1]);
                  } else {
                    FocusScope.of(context).unfocus(); // Non ci sono più numeri da inserire
                  }
                } else if (value.isEmpty) {
                  // Cancellazione: Sposta il focus al campo precedente
                  if (index > 0) {
                    // Questa logica viene gestita dal RawKeyboardListener
                    // ma la manteniamo qui per il comportamento standard di Android/iOS
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