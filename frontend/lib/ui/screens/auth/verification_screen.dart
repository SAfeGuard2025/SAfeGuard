import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/ui/screens/auth/login_screen.dart';
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
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
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
                      "Abbiamo inviato un codice OTP.\nInseriscilo per verificare la tua identità.",
                      style: TextStyle(color: textWhite, fontSize: 18, height: 1.5),
                    ),
                    const SizedBox(height: 60),

                    // GRIGLIA DI INPUT (6 Cifre)
                    _buildVerificationCodeInput(context),

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
                            : const Text(
                          "VERIFICA",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TIMER RINVIO CODICE
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
                              if (authProvider.secondsRemaining == 0) {
                                authProvider.startTimer();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Nuovo codice inviato!")),
                                );
                                // Resetta i campi
                                for (var c in _codeControllers) c.clear();
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
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline,
                                decorationColor: authProvider.secondsRemaining == 0
                                    ? textWhite
                                    : textWhite.withValues(alpha: 0.5),
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

  // --- LOGICA INPUT MIGLIORATA ---

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
          children: List.generate(3, (index) => _buildCodeBox(index + 3, context)),
        ),
      ],
    );
  }

  Widget _buildCodeBox(int index, BuildContext context) {
    final boxSize = MediaQuery.of(context).size.width / 6;

    // Usiamo RawKeyboardListener per intercettare il Backspace anche a campo vuoto
    return RawKeyboardListener(
      focusNode: FocusNode(), // Nodo fittizio per il listener (non quello del TextField)
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.backspace) {
            // Se premo backspace e il campo attuale è vuoto, sposto il focus indietro
            if (_codeControllers[index].text.isEmpty && index > 0) {
              _codeFocusNodes[index - 1].requestFocus();
              // Opzionale: cancella anche il valore precedente se vuoi essere aggressivo
              // _codeControllers[index - 1].clear(); 
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
              focusNode: _codeFocusNodes[index], // FONDAMENTALE: Collega il nodo
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,

              // Impedisce caratteri non numerici (., - space)
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],

              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: darkBluePrimary,
              ),
              decoration: const InputDecoration(
                counterText: "",
                border: InputBorder.none,
                // Centra verticalmente il cursore/testo
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),

              onChanged: (value) {
                if (value.length == 1) {
                  // Inserimento: Passa al prossimo
                  if (index < 5) {
                    FocusScope.of(context).requestFocus(_codeFocusNodes[index + 1]);
                  } else {
                    FocusScope.of(context).unfocus(); // Fine inserimento
                  }
                } else if (value.isEmpty) {
                  // Cancellazione (Backspace su campo pieno): Passa al precedente
                  if (index > 0) {
                    FocusScope.of(context).requestFocus(_codeFocusNodes[index - 1]);
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