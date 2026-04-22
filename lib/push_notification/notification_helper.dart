import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:mahakal/main.dart';
import 'package:mahakal/push_notification/models/notification_body.dart';
import 'package:mahakal/utill/app_constants.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/screens/auth_screen.dart';
import '../features/chat/screens/inbox_screen.dart';
import '../features/custom_bottom_bar/bottomBar.dart';
import '../features/notification/screens/notification_screen.dart';
import '../features/order_details/screens/order_details_screen.dart';

class NotificationHelper {
  static FlutterLocalNotificationsPlugin? _flnPlugin;

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    _flnPlugin = flutterLocalNotificationsPlugin;
    
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('notification_icon');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    
    await flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        try {
          if (response.payload != null && response.payload!.isNotEmpty) {
            final payload = NotificationBody.fromJson(jsonDecode(response.payload!));
            handleNotificationNavigation(payload);
          }
        } catch (e) {
          dev.log('Notification tap error: $e', name: 'NotificationHelper');
        }
      },
    );

    // Firebase foreground message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      dev.log('Foreground message received: ${message.data}', name: 'NotificationHelper');
      
      if (['audio', 'video', 'chat'].contains(message.data['type'])) {
        showCallkitIncoming(message.data, 'foreground');
        return;
      }
      
      showNotification(message, false); 
    });

    // App opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final notificationBody = convertNotification(message.data);
      handleNotificationNavigation(notificationBody);
    });
  }

  static NotificationBody convertNotification(Map<String, dynamic> data) {
    try {
      return NotificationBody.fromJson(data);
    } catch (e) {
      dev.log('Convert notification failed: $e', name: 'NotificationHelper');
      return NotificationBody();
    }
  }

  static Future<void> showNotification(RemoteMessage message, bool isDataOnly) async {
    if (_flnPlugin == null) return;
    
    final notificationBody = convertNotification(message.data);
    final notificationId = DateTime.now().millisecondsSinceEpoch.hashCode.abs();
    
    String? title = isDataOnly ? message.data['title'] : message.notification?.title ?? message.data['title'];
    String? body = isDataOnly ? message.data['body'] : message.notification?.body ?? message.data['body'];
    String? imageUrl = _getImageUrl(message);
    
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        await _showBigPictureNotification(title, body, notificationBody, imageUrl, notificationId);
      } catch (e) {
        await _showBigTextNotification(title, body!, notificationBody, notificationId);
      }
    } else {
      await _showBigTextNotification(title, body!, notificationBody, notificationId);
    }
  }

  static Future<void> _showBigTextNotification(String? title, String body, NotificationBody bodyData, int id) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mahakal_channel',
      'Mahakal Notifications',
      channelDescription: 'General notifications',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    final NotificationDetails notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    await _flnPlugin!.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: jsonEncode(bodyData.toJson()),
    );
  }

  static Future<void> _showBigPictureNotification(String? title, String? body, NotificationBody bodyData, String imageUrl, int id) async {
    final largeIconPath = await _downloadFile(imageUrl, 'icon_$id.png');
    final bigPicturePath = await _downloadFile(imageUrl, 'picture_$id.png');
    
    final styleInfo = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      contentTitle: title,
      summaryText: body,
    );
    
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mahakal_image_channel',
      'Mahakal Image Notifications',
      channelDescription: 'Notifications with images',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: styleInfo,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    final NotificationDetails notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    await _flnPlugin!.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: jsonEncode(bodyData.toJson()),
    );
  }

  static String? _getImageUrl(RemoteMessage message) {
    String? image = message.data['image'] ?? 
                   message.notification?.android?.imageUrl ?? 
                   message.notification?.apple?.imageUrl;
    
    if (image == null || image.isEmpty) return null;
    return image.startsWith('http') ? image : '${AppConstants.baseUrl}/storage/app/public/notification/$image';
  }

  static Future<String> _downloadFile(String url, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/notifications/$filename');
    await file.parent.create(recursive: true);
    
    final response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  static void handleNotificationNavigation(NotificationBody body) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = Get.context;
      if (context == null) {
        dev.log('No context for navigation', name: 'NotificationHelper');
        return;
      }

      switch (body.type) {
        case 'order_details':
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(orderId: int.tryParse(body.orderId?.toString() ?? '')),
          ));
          break;
        case 'chat':
        case 'astrotalk':
          Navigator.push(context, MaterialPageRoute(builder: (_) => InboxScreen(scrollController: ScrollController())));
          break;
        // case 'pooja':
        // case 'anushthan':
        //   Navigator.push(context, MaterialPageRoute(
        //     builder: (_) => SliversExample(slugName: body.service_id.toString()),
        //   ));
        //   break;
        // case 'donation':
        //   Navigator.push(context, MaterialPageRoute(builder: (_) => Donationpage(myId: null)));
        //   break;
        case 'notification':
          Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen()));
          break;
        case 'block':
          Provider.of<AuthController>(context, listen: false).clearSharedData();
          Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => AuthScreen()),
            (route) => false,
          );
          break;
        default:
          Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => BottomBar(pageIndex: 0)),
            (route) => false,
          );
      }
    });
  }

  static void showCallkitIncoming(Map<String, dynamic> data, String handleType) {
    try {
      final params = CallKitParams(
        id: const Uuid().v4(),
        nameCaller: data['caller_name'] ?? 'Mahakal Call',
        appName: 'Mahakal',
        type: 0, // incoming
        handle: data['astrologer_id'] ?? '',
        avatar: data['avatar'] ?? '',
        extra: data,
      );
      FlutterCallkitIncoming.showCallkitIncoming(params);
    } catch (e) {
      dev.log('Callkit incoming error: $e', name: 'NotificationHelper');
    }
  }
}
