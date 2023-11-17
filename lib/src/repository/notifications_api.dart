import 'dart:collection';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/constants.dart';

class NotificationsApi {
  NotificationsApi._();
  static final instance = NotificationsApi._();

  var _initialized = false;
  final _notification = FlutterLocalNotificationsPlugin();
  final _notificationIdQueue = ListQueue();

  get _darwinSettings {
    return const DarwinInitializationSettings();
  }

  get _defaultDarwinDetails {
    return const DarwinNotificationDetails(
      presentAlert: true,
      presentList: true,
      presentSound: true,
    );
  }

  void ensureInitialized() async {
    if (_initialized) {
      return;
    }
    await _initialize();
  }

  Future<void> _initialize() async {
    _initialized = await _notification.initialize(
          InitializationSettings(macOS: _darwinSettings),
        ) ??
        false;
  }

  void show(String message) {
    final id = _notificationIdQueue.length;
    _notification.show(
      id,
      kAppName,
      message,
      NotificationDetails(
        macOS: _defaultDarwinDetails,
      ),
    );
  }

  void hide() {
    final id = _notificationIdQueue.first;
    _notification.cancel(id);
  }
}
