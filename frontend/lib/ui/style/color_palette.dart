import 'package:flutter/material.dart';

/*
* Heyo
*
* Questa è la palette della app
* Questi commenti saranno eliminati dopo l'unificazione e la rielaborazione
* dei file citati sotto
* Ho incluso ogni codice esadecimale dichiarato manualmente nei file,
* bisogna andare in ognuno e sostituirlo con un riferimento da questa lista,
* così si può fare un refactor dopo e rinominare tutti i colori uguali, tenendo
* quelli che andrebbero separati separati
*
* Consiglio: sono tutti ordinati così come appaiono nella lista estesa dei file
* nella cartella ui, spero non sia troppo uno sbatti trovare i colori
* corrispondenti <3
* */


class ColorPalette {
  // Costruttore privato per impedire l'istanziamento
  ColorPalette._();

  // ---------------------------------------------------------------------------
  // BLU E SFONDI SCURI
  // ---------------------------------------------------------------------------

  /// Blu molto scuro (quasi nero). Usato per sfondi Auth e Login.
  static const Color backgroundDeepBlue = Color(0xFF041528);

  /// Blu scuro intermedio. Usato per sfondi generali di schermate mediche/profilo.
  static const Color backgroundMidBlue = Color(0xFF12345A);

  /// Blu scuro "Petrolio". Usato massicciamente per Card, Placeholder mappe e sfondi User.
  static const Color backgroundDarkBlue = Color(0xFF0E2A48);

  /// Blu bottone standard.
  static const Color primaryDarkButtonBlue = Color(0xFF0A2540);

  /// Blu di controllo/accento (più chiaro dei background).
  static const Color accentControlBlue = Color(0xFF152F4E);

  /// Blu specifico per il bottone di verifica.
  static const Color verificationButtonBlue = Color(0xFF1B3C5E);

  /// Blu per la Navigation Bar dell'Utente Cittadino.
  static const Color navBarUserBackground = Color(0xFF16273F);

  /// blu per notifica soccorritore
  static const Color electricBlue = Color(0xFF1000ef);

  /// Blu profondo usato per le sfumature (Gradienti).

  static const Color gradientDeepBlue = Color.fromARGB(255, 10, 30, 50);

  // ---------------------------------------------------------------------------
  // ARANCIONI (Tema Soccorritore & Accent)
  // ---------------------------------------------------------------------------

  /// Arancione primario vivace. (Nota: Unificato 0xFFEF923D e 0xFFEF932D).
  static const Color primaryOrange = Color(0xFFEF923D);

  /// Arancione scuro/bruciato. Usato per le Card del soccorritore.
  static const Color cardDarkOrange = Color(0xFFD65D01);

  /// Arancione medio/pastello. Usato per testi o icone secondarie.
  static const Color accentMediumOrange = Color(0xFFE08E50);

  /// Arancione ambra.
  static const Color amberOrange = Color(0xFFFF9800);

  /// Marrone/Arancione scuro per Navigation Bar del Soccorritore.
  static const Color navBarRescuerBackground = Color(0xFF995618);

  // ---------------------------------------------------------------------------
  // ROSSI (Emergenza & Cancellazione)
  // ---------------------------------------------------------------------------

  /// Rosso acceso (Puro). Bottone SOS.
  static const Color emergencyButtonRed = Color(0xFFFF0000);

  /// Rosso vivo. Conferme emergenza.
  static const Color primaryBrightRed = Color(0xFFE53935);

  /// Rosso chiaro/pastello. Usato per icone cestino o azioni di eliminazione.
  static const Color deleteRed = Color(0xFFFF5555);

  /// Rosso scuro sangue. Sfondo dello swipe.
  static const Color swipeDarkRed = Color(0xFF8B1D1D);

  // ---------------------------------------------------------------------------
  // VARI (Gialli, Ciani)
  // ---------------------------------------------------------------------------

  /// Giallo ape (Evidenziatore).
  static const Color accentBeeYellow = Color(0xFFFFFF00);

  /// Giallo oro per icone profilo.
  static const Color iconAccentYellow = Color(0xFFE3C63D);

  /// Ciano per barre di caricamento.
  static const Color progressCyan = Color(0xFF00B0FF);
}