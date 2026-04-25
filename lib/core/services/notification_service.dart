import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles Firebase Cloud Messaging in every app state.
///
/// • Foreground  → shows a local notification banner via [FlutterLocalNotificationsPlugin]
/// • Background  → Android/iOS system tray (handled by FCM automatically)
/// • Terminated  → same as background
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  // High-importance channel for admin broadcasts
  static const _channelId = 'skillswap_admin';
  static const _channelName = 'SkillSwap Admin';
  static const _channelDesc = 'Important messages from the SkillSwap team';

  Future<void> init() async {
    // ── Android channel ──────────────────────────────────────────────────────
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    // ── Plugin init settings ─────────────────────────────────────────────────
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission:
            false, // already requested via FirebaseMessaging
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          try {
            final data = json.decode(details.payload!);
            final notificationId = data['notification_id'];
            if (notificationId != null) {
              _markAsRead(notificationId);
            }
          } catch (_) {}
        }
      },
    );

    // ── Background FCM messages (System Tray) ────────────────────────────────
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final notificationId = message.data['notification_id'];
      if (notificationId != null) {
        _markAsRead(notificationId);
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final notificationId = message.data['notification_id'];
        if (notificationId != null) {
          _markAsRead(notificationId);
        }
      }
    });

    // ── Foreground FCM messages ──────────────────────────────────────────────
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Tell FCM to show heads-up notifications even while the app is open
    // (only on Android — iOS handles this differently)
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    if (kDebugMode) {
      print('[NotificationService] Initialised ✅');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    if (kDebugMode) {
      print('[NotificationService] Foreground message: ${notification.title}');
    }

    _plugin.show(
      // Use hashCode so rapid messages don't overwrite each other
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          icon: '@mipmap/ic_launcher',
          // Show the full message without truncation
          styleInformation: BigTextStyleInformation(
            notification.body ?? '',
            contentTitle: notification.title,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: json.encode(message.data),
    );
  }

  /// Call this to manually show a local notification (useful for testing).
  Future<void> showTest() async {
    _handleForegroundMessage(
      RemoteMessage(
        notification: const RemoteNotification(
          title: '🔔 Test Notification',
          body: 'If you can see this, notifications are working!',
        ),
      ),
    );
  }

  void _markAsRead(String notificationId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'is_read': true}).catchError((_) {});
    }
  }
}

/// Top-level function required by FCM for background message handling.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized when this runs.
  // Background notifications are displayed automatically by the OS —
  // we only need this handler for silent data messages.
  if (kDebugMode) {
    print('[FCM Background] ${message.notification?.title}');
  }
}
