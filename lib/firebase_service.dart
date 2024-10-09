import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// Firebase Messaging Service
class FirebaseService {
  static Future<void> setupFCM() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await requestPermission();
    await getToken();
  }

  static Future<void> requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User denied permission');
    }
  }

  static Future<void> getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
    // You can store the token in your database for the Kuli here
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Handle background messages here.
    print("Handling a background message: ${message.messageId}");
  }
}
