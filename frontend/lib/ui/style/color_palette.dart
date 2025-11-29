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
  //Costruttore statico per impedire le istanze
  ColorPalette._();
  static Color beeYellow = const Color(0xFFFFFF00);
  //Cartelle fatte finora = home, auth, map, reports, medical, profile, widgets
  //In corso = nessuno :D

  //Colori da email_login_screen
  static Color emailLoginButtonColor = const Color(0xFF0A2540);
  static Color emailLoginBlue = const Color(0xFF041528); //Riga 59

  //Colori da email_register_screen
  static Color emailRegisterButtonColor = const Color(0xFF0A2540);
  static Color emailRegisterBlue = const Color(0xFF041528); //Riga 59

  //Colori da loading_screen
  static Color loadingScreenDarkBackground = const Color(0xFF12345A);
  static Color loadingScreenProgressCyan = const Color(0xFF00B0FF);

  //Colori da login_screen
  static Color loginScreenDarkBlue = const Color(0xFF041528);

  //Colori da phone_login_screen
  static Color phoneLoginButtonColor = const Color(0xFF0A2540);
  static Color phoneLoginDarkBlue = const Color(0xFF041528); //Riga 59

  //Colori da phone_register_screen
  static Color phoneRegisterButtonColor = const Color(0xFF0A2540);
  static Color phoneRegisterDarkBlue = const Color(0xFF041528); //Riga 60

  //Colori da registration_screen
  static Color registrationScreenDarkBlue = const Color(0xFF041528);

  //Colori da verification_screen
  static Color verificationScreenDarkBluePrimary = const Color(0xFF12345A);
  static Color verificationScreenDarkBlueButton = const Color(0xFF1B3C5E);

  //Colori confirm_emergency_screen
  static Color confirmEmergencyBrightRed = const Color(0xFFE53935);

  //Colori di home_page_content
  static Color homePageContentDarkBlue = const Color(0xFF041528);
  static Color homePageContentPrimaryRed = const Color(0xFFE53935);
  static Color homePageContentAmberOrange = const Color(0xFFFF9800);
  static Color homePageContentMapPlaceholder = const Color(0xFF0E2A48); //riga 79

  //Colori di home_screen
  static Color homeScreenRescuerBackgroundColor = const Color(0xFFef923d);
  static Color homeScreenUserBackgroundColor = const Color(0xFF0e2a48);

  //Colori di map_screen
  static Color mapScreenMapPlaceholder = const Color(0xFF0E2A48); //Riga 23

//Colori di allergie_screen
  static Color allergiesBgColor = const Color(0xFF12345A);
  static Color allergiesCardColor = const Color(0xFF0E2A48);
  static Color allergiesDeleteColor = const Color(0xFFFF5555);
  static Color allergiesAddBtnColor = const Color(0xFF152F4E);
  static Color allergiesBackgroundColor = const Color(0xFF0E2A48);  //Riga 181

//Colori di condizioni_mediche_screen
  static Color conditionsBgColor = const Color(0xFF12345A);
  static Color conditionsCardColor = const Color(0xFF0E2A48);
  static Color conditionsActiveSwitchColor = const Color(0xFFEF923D);

//Colori di contatti_emergenza_screen
  static Color emContactsBgColor = const Color(0xFF12345A);
  static Color emContactsCardColor = const Color(0xFF0E2A48); //Appare sia nelle dichiarazioni che in riga 243
  static Color emContactsDeleteColor = const Color(0xFFFF5555);
  static Color emContactsOrange = const Color(0xFFE08E50);  //Riga 69 nice
  static Color emContactsBlue = const Color(0xFF152F4E);  //Riga 141

//Colori di gestione_cartella_clinica_screen
  static Color clinicalRescuerCardColor = const Color(0xFFD65D01);
  static Color clinicalRescuerBgColor = const Color(0xFFEF932D);
  static Color clinicalUserCardColor = const Color(0xFF12345A);
  static Color clinicalUserBgColor = const Color(0xFF0E2A48);

//Colori di medicinali_screen
  static Color medicalBgColor = Color(0xFF12345A);
  static Color medicalCardColor = Color(0xFF0E2A48); //Anche a riga 213
  static Color medicalDeleteColor = Color(0xFFFF5555);
  static Color medicalOrange = Color(0xFFE08E50); // Riga 65
  static Color medicalBlue = const Color(0xFF152F4E); // Riga 136

//Colori di gestione_modifica_profilo_cittadino
  static Color modProfRescuerBgColor = const Color(0xFFEF923D); //Da riga 103
  static Color modProfRescuerCardColor = const Color(0xFFD65D01);
  static Color modProfRescuerAccentColor = const Color(0xFF12345A);
  static Color modProfUserBgColor = const Color(0xFF12345A);
  static Color modProfUserCardColor = const Color(0xFF0E2A48);
  static Color modProfUserAccentColor = const Color(0xFFEF923D);
  static Color modProfIconColor = const Color(0xFFE3C63D);

  //Colori di gestore_notifiche_cittadino
  static Color gestNotRescuerBgColor = const Color(0xFFEF923D); //Da riga 34
  static Color gestNotRescuerCardColor = const Color(0xFFD65D01);
  static Color gestNotRescuerAccentColor = const Color(0xFF12345A);
  static Color gestNotUserBgColor = const Color(0xFF12345A);
  static Color gestNotUserCardColor = const Color(0xFF0E2A48);
  static Color gestNotUserAccentColor = const Color(0xFFEF923D);

  //Colori di gestore_permessi_cittadino
  static Color gestPerRescuerBgColor = const Color(0xFFEF923D); //Da riga 27
  static Color gestPerRescuerCardColor = const Color(0xFFD65D01);
  static Color gestPerRescuerAccentColor = const Color(0xFF12345A);
  static Color gestPerUserBgColor = const Color(0xFF12345A);
  static Color gestPerUserCardColor = const Color(0xFF0E2A48);
  static Color gestPerUserAccentColor = const Color(0xFFEF923D);

  //Colori di profile_settings_screen
  static Color profSetRescuerCardColor = const Color(0xFFD65D01); //Riga 65
  static Color profSetRescuerBgColor = const Color(0xFFEF932D);
  static Color profSetRescuerAccentColor = const Color(0xFFEF932D);
  static Color profSetUserCardColor = const Color(0xFF12345A);
  static Color profSetUserBgColor = const Color(0xFF0E2A48);
  static Color profSetUserAccentColor = const Color(0xFF0E2A48);

  //Colori di custom_bottom_nav_bar
  static Color navBarRescuerbackgroundColor = const Color(0xFF995618); //Da riga 26
  static Color navBarUserbackgroundColor = const Color(0xFF16273F);
  static Color navBarSelectedItemColor = const Color(0xFFEF923D);

  //Colori di emergency_item
  static Color emergencyItemButtonColor = const Color(0xFFFF0000);

  //Colori di swipe_to_confirm
  static Color swipeBackGroundColor = const Color(0xFF8B1D1D); //Riga 43

//Colori di reports_screen
  //Nessuno ad ora
}
