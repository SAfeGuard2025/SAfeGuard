import 'package:flutter/material.dart';
// Rimosso import 'package:flutter/services.dart';
import 'dart:async';

import 'package:flutter/services.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // --- Definizioni Colori ---
  static const Color darkBluePrimary = Color(0xFF12345A); // Blu scuro principale (sfondo)
  static const Color darkBlueButton = Color(0xFF1B3C5E); // Blu scuro per il bottone
  static const Color textWhite = Colors.white;

  // --- Gestione del Timer per il Rinvio Codice ---
  int _secondsRemaining = 30;
  late Timer _timer;

  // --- Controllers e FocusNodes per i campi di input del codice ---
  final List<TextEditingController> _codeControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeFocusNodes =
  List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel(); // Annulla il timer quando il widget viene eliminato

    // Pulisce e rilascia i controllers e i focus nodes
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _codeFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 30; // Reset del contatore
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          timer.cancel(); // Ferma il timer
        });
      } else {
        setState(() {
          _secondsRemaining--; // Decrementa i secondi
        });
      }
    });
  }

  void _resendCode() {
    if (_secondsRemaining == 0) {
      // Logica per inviare nuovamente il codice (es. chiamata API)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Codice inviato nuovamente.")),
      );
      _startTimer(); // Riavvia il timer
      // Pulisci tutti i campi di input dopo il rinvio
      for (var controller in _codeControllers) {
        controller.clear();
      }
      _codeFocusNodes[0].requestFocus(); // Metti il focus sul primo campo
    }
  }

  // Funzione per ottenere il codice completo inserito
  String _getVerificationCode() {
    return _codeControllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    // Uso MediaQuery per ottenere l'altezza dello schermo meno il padding superiore di SafeArea
    final double viewHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    return Scaffold(
      // Applica il gradiente direttamente al body o allo Scaffold se preferisci
      backgroundColor: darkBluePrimary,

      body: Container(
        // Simula la curva sullo sfondo applicando il gradiente all'intero contenitore del body
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              darkBluePrimary,
              Color.fromARGB(255, 10, 30, 50), // Leggera variazione di scuro
            ],
          ),
        ),

        // Uso un SafeArea per gestire la barra di stato/navigazione
        child: SafeArea(
          // Uso un SizedBox per dare alla colonna un'altezza massima,
          // forzando il contenuto a riempire lo spazio.
          child: SizedBox(
            height: viewHeight,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30), // Spazio iniziale ridotto

                  // 1. TITOLO
                  const Text(
                    "Codice di verifica",
                    style: TextStyle(
                      color: textWhite,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. DESCRIZIONE
                  const Text(
                    "Abbiamo inviato un codice all'email inserita.\nInseriscilo per verificare la tua identità",
                    style: TextStyle(
                      color: textWhite,
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 80),

                  // 3. CAMPI DI INPUT (Grid per 6 cifre)
                  _buildVerificationCodeInput(context),

                  // ----------------------------------------------------
                  // *** MODIFICA CHIAVE: Uso di Spacer ***
                  const Spacer(),
                  // ----------------------------------------------------

                  // 4. BOTTONE "VERIFICA"
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        final enteredCode = _getVerificationCode();
                        // Logica di verifica del codice qui
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "Codice inserito: $enteredCode. Verifica in corso...")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlueButton,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 8,
                      ),
                      child: const Text(
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

                  // 5. TESTO PER IL RINVIO (Timer)
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          "Non hai ricevuto il codice?",
                          style: TextStyle(
                            color: textWhite,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: _resendCode,
                          child: Text(
                            _secondsRemaining == 0
                                ? "Invia di nuovo il codice"
                                : "Rinvia il codice (0:${_secondsRemaining.toString().padLeft(2, '0')})",
                            style: TextStyle(
                              color: _secondsRemaining == 0
                                  ? textWhite
                                  : textWhite.withOpacity(0.5),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline,
                              decorationColor: _secondsRemaining == 0
                                  ? textWhite
                                  : textWhite.withOpacity(0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5), // Piccolo margine finale
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget per la griglia di input a 6 cifre
  Widget _buildVerificationCodeInput(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
              3, (index) => _buildCodeBox(index, context)),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
              3, (index) => _buildCodeBox(index + 3, context)),
        ),
      ],
    );
  }

  // Widget singolo campo di input OTTIMIZZATO SENZA RawKeyboardListener
  // Widget singolo campo di input OTTIMIZZATO con RawKeyboardListener
  Widget _buildCodeBox(int index, BuildContext context) {
    final boxSize = MediaQuery.of(context).size.width / 6;

    // *** UTILIZZO RawKeyboardListener per intercettare il tasto 'Delete' ***
    return RawKeyboardListener(
      // Assegna il FocusNode al Listener
      focusNode: _codeFocusNodes[index],
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          // Controlla se il tasto premuto è il backspace/delete
          if (event.logicalKey == LogicalKeyboardKey.backspace ||
              event.logicalKey == LogicalKeyboardKey.delete) {

            // Logica: Se il campo attuale è VUOTO E non è il primo campo
            if (_codeControllers[index].text.isEmpty && index > 0) {

              // 1. Pulisce il campo precedente
              _codeControllers[index - 1].clear();

              // 2. Sposta il focus al campo precedente
              FocusScope.of(context).requestFocus(_codeFocusNodes[index - 1]);

              // Importante: non tentiamo di gestire l'evento, lasciamo che il sistema lo gestisca
              // per minimizzare i problemi di chiusura della tastiera. La navigazione è il nostro obiettivo.
            }
          }
        }
      },
      child: SizedBox(
        width: boxSize, // Larghezza del singolo box resa dinamica
        height: boxSize,
        child: Container(
          decoration: BoxDecoration(
            color: textWhite.withOpacity(0.9), // Reso più opaco (90%) per chiarezza
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: TextField(
              controller: _codeControllers[index],
              // NON assegniamo il FocusNode al TextField, è gestito dal RawKeyboardListener esterno
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
                // 1. Logica di AVANZAMENTO (Digitazione) - Funziona fluidamente
                if (value.length == 1) {
                  if (index < 5) {
                    FocusScope.of(context).requestFocus(_codeFocusNodes[index + 1]);
                  } else {
                    FocusScope.of(context).unfocus();
                  }
                }

                // 2. Logica di CANCELLAZIONE FLUIDA (Campo Pieno -> Campo Vuoto)
                // Questa logica rimane in caso di pressione di backspace su campo pieno
                else if (value.isEmpty && index > 0) {
                  // Se RawKeyboardListener fallisce per la transizione pieno->vuoto,
                  // questa logica fallback funziona
                  _codeControllers[index - 1].clear();
                  FocusScope.of(context).requestFocus(_codeFocusNodes[index - 1]);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}