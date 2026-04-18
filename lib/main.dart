import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:developer' as dev;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mahakal/my_app.dart';
import 'package:mahakal/provider_registry.dart';
import 'package:mahakal/push_notification/models/notification_body.dart';
import 'package:mahakal/push_notification/notification_helper.dart';
import 'package:provider/provider.dart';
import 'package:media_kit/media_kit.dart';
import 'di_container.dart' as di;
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('📩 Background message: ${message.data}');
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FlutterDownloader
  await FlutterDownloader.initialize(
    debug: true,
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  MediaKit.ensureInitialized();
  await di.init();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // HttpOverrides.global = MyHttpOverrides(); // TODO: Remove insecure SSL bypass in production
  NotificationBody? launchBody;

  try {
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      launchBody = NotificationHelper.convertNotification(initialMessage.data);
      print('🔔 App opened from terminated state via notification');
    }
  } catch (e) {
    print('❌ Error reading initial tap: $e');
  }

  runApp(
    MultiProvider(
      providers: providers,
      child: MyApp(
        body: launchBody,
        navigatorKey: navigatorKey,
      ),
    ),
  );

  // Defer FlutterCallkitIncoming initialization to after app is fully ready
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeCallkitPermissions();
  });

  Future.microtask(() async {
    await initializeNotifications();
    await _initializeCallkitPermissions();
  });
}

Future<void> _initializeCallkitPermissions() async {
  try {
    if (Platform.isIOS) {
      // Add a small delay to ensure iOS runtime is fully ready
      await Future.delayed(const Duration(milliseconds: 500));
      await FlutterCallkitIncoming.requestFullIntentPermission();
      dev.log('🚀 FlutterCallkitIncoming permissions requested',
          name: 'main.dart');
    }
  } catch (e) {
    dev.log('⚠️ FlutterCallkitIncoming permission request failed: $e',
        name: 'main.dart');
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> initializeNotifications() async {
  try {
    // Request Android notifications permission (Android 13+)
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    // Request FCM permissions for all platforms
    final NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    dev.log('Notification permission status: ${settings.authorizationStatus}',
        name: 'initializeNotifications');

    // Local Notification Setup
    await NotificationHelper.initialize(flutterLocalNotificationsPlugin);

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    print('✅ Notifications initialized');
  } catch (e) {
    print('❌ Notification init failed: $e');
    dev.log('Notification initialization error: $e',
        name: 'initializeNotifications');
  }
}

class Get {
  static BuildContext? get context => navigatorKey.currentContext;
  static NavigatorState? get navigator => navigatorKey.currentState;
}
