//OTP

//PROBLEMI SULL'INSERIMENTO E SULLA CANCELLAZIONE DEI NUMERI INSERITI NEI RIQUADRI

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Serve per RawKeyboardListener
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/screens/home/home_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // COLORI
  static const Color darkBluePrimary = Color(0xFF12345A);
  static const Color darkBlueButton = Color(0xFF1B3C5E);
  static const Color textWhite = Colors.white;

  // I controller rimangono qui perché sono legati strettamente ai widget di input UI
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

  // Helper per unire i 6 numeri in una stringa unica
  String _getVerificationCode() => _codeControllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    // Colleghiamo il provider per leggere Timer e Stato Caricamento
    final authProvider = Provider.of<AuthProvider>(context);

    // Calcolo altezza view
    final double viewHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: darkBluePrimary,
      body: Container(
        // Sfondo con gradiente
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [darkBluePrimary, Color.fromARGB(255, 10, 30, 50)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: viewHeight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Tasto Indietro
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),

                    const SizedBox(height: 20),

                    // Titoli
                    const Text(
                      "Codice di verifica",
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Abbiamo inviato un codice.\nInseriscilo per verificare la tua identità.",
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 60),

                    //  GRIGLIA DI INPUT (6 Cifre)
                    _buildVerificationCodeInput(context),

                    const Spacer(),

                    // BOTTONE VERIFICA
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                final code = _getVerificationCode();

                                if (code.length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Inserisci il codice completo",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // Chiamata al Provider
                                bool success = await authProvider.verifyCode(
                                  code,
                                );

                                if (success && mounted) {
                                  // Navigazione alla Home e rimozione della storia precedente
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBlueButton,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "VERIFICA",
                                style: TextStyle(
                                  color: textWhite,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TESTO RINVIO CODICE
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            "Non hai ricevuto il codice?",
                            style: TextStyle(color: textWhite, fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () {
                              // Permetti il rinvio solo se il timer è a 0
                              if (authProvider.secondsRemaining == 0) {
                                // Qui dovresti passare il numero di telefono salvato o chiederlo di nuovo
                                // Per ora simuliamo il rinvio
                                authProvider.startTimer();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Codice rinviato!"),
                                  ),
                                );

                                // Pulisci i campi e rimetti il focus al primo
                                for (var c in _codeControllers) {
                                  c.clear();
                                }
                                _codeFocusNodes[0].requestFocus();
                              }
                            },
                            child: Text(
                              authProvider.secondsRemaining == 0
                                  ? "Invia di nuovo il codice"
                                  : "Rinvia il codice (0:${authProvider.secondsRemaining.toString().padLeft(2, '0')})",
                              style: TextStyle(
                                color: authProvider.secondsRemaining == 0
                                    ? textWhite
                                    : textWhite.withValues(alpha: 0.5),
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    authProvider.secondsRemaining == 0
                                    ? textWhite
                                    : textWhite.withValues(alpha: 0.5)
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // LOGICA DI INPUT VISIVA

  Widget _buildVerificationCodeInput(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) => _buildCodeBox(index, context)),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (index) => _buildCodeBox(index + 3, context),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeBox(int index, BuildContext context) {
    final boxSize = MediaQuery.of(context).size.width / 6;

    // RawKeyboardListener serve per intercettare il tasto Backspace anche quando il campo è vuoto
    return KeyboardListener(
      focusNode: _codeFocusNodes[index],
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.backspace ||
              event.logicalKey == LogicalKeyboardKey.delete) {
            // Se premo backspace su un campo vuoto, vado a quello prima e cancello
            if (_codeControllers[index].text.isEmpty && index > 0) {
              _codeControllers[index - 1].clear();
              FocusScope.of(context).requestFocus(_codeFocusNodes[index - 1]);
            }
          }
        }
      },
      child: SizedBox(
        width: boxSize,
        height: boxSize,
        child: Container(
          decoration: BoxDecoration(
            color: textWhite.withValues(alpha: 0.5),
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
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: darkBluePrimary,
              ),
              decoration: const InputDecoration(
                counterText: "",
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 2),
              ),
              onChanged: (value) {
                // AVANZAMENTO AUTOMATICO CHE NON FUNZIONA
                if (value.length == 1) {
                  if (index < 5) {
                    FocusScope.of(
                      context,
                    ).requestFocus(_codeFocusNodes[index + 1]);
                  } else {
                    FocusScope.of(
                      context,
                    ).unfocus(); // CHIUSURA DELLA TASTIERA ALLA FINE DELLA SCRITTURA DI OGNI CASELLA
                  }
                }
                // Cancellazione
                else if (value.isEmpty && index > 0) {
                  _codeControllers[index - 1].clear();
                  FocusScope.of(
                    context,
                  ).requestFocus(_codeFocusNodes[index - 1]);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
