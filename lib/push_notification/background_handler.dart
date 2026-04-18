import 'dart:developer' as dev;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_helper.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized in main(), no need to reinitialize
  dev.log('Background message: ${message.data}', name: 'BackgroundHandler');
  
  final FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();
  await NotificationHelper.initialize(fln);
  
  // Check if it's a call notification
  if (['audio', 'video', 'chat'].contains(message.data['type'])) {
    NotificationHelper.showCallkitIncoming(message.data, 'background');
  } else {
    await NotificationHelper.showNotification(message, true);
  }
}
