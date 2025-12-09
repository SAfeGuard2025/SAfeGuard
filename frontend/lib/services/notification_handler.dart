import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/screens/home/safe_check_screen.dart';

// Handler top-level per i messaggi in background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Messaggio in background: ${message.messageId}");
}

class NotificationHandler {
  // Singleton pattern
  static final NotificationHandler _instance = NotificationHandler._internal();
  factory NotificationHandler() => _instance;
  NotificationHandler._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Configurazione del canale Android
  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'emergency_channel_v3', // ID univoco
    'Allerte di Emergenza',
    description: 'Notifiche critiche per le emergenze',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  // Inizializza tutto il sistema di notifiche
  Future<void> initialize() async {
    // 1. Richiesta permessi (iOS e Android 13+)
    await _requestPermissions();

    // 2. Setup Notifiche Locali
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        debugPrint("Notifica cliccata: ${response.payload}");
      },
    );

    // 3. Setup Canale Android
    await _setupAndroidChannel();

    // 4. Setup Listener Firebase (Foreground)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Setup Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Richiesta permessi
  Future<void> _requestPermissions() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );
  }

  Future<void> _setupAndroidChannel() async {
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Pulizia vecchi canali
      await androidPlugin.deleteNotificationChannel('emergency_channel');
      await androidPlugin.createNotificationChannel(_androidChannel);
    }
  }

  // Gestisce la ricezione della notifica quando l'app è aperta
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint("Messaggio in Foreground: ${message.notification?.title}");

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      // Genera un ID univoco per evitare sovrascritture
      final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      //Mostra la notifica in foreground rispetto all app
      _localNotifications.show(
        id,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true, // Mostra sopra le altre app se possibile
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            styleInformation: BigTextStyleInformation(notification.body ?? ''),
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }

    //LOGICA AUTOMATICA: APERTURA PAGINA
    // Controlla se è un alert critico
    if (message.data['type'] == 'emergency_alert' || message.data['type'] == 'safe_check') {

      debugPrint("🚨 ALLERTA RILEVATA: Apro SafeCheckScreen automaticamente...");

      // Estrae i dati dal messaggio (se il backend li manda, altrimenti usa default)
      final String title = message.notification?.title ?? "ALLERTA DI SICUREZZA";

      // Usa la navigatorKey per "spingere" la pagina sopra a tutto
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => SafeCheckScreen(
            title: title,
          ),
        ),
      );
    }
  }

  // Metodo pubblico per ottenere il token FCM
  Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}