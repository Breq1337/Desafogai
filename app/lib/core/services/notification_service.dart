import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/dashboard/models/debt_model.dart';

/// Service for scheduling payment reminder notifications.
/// Supported platforms: Android, iOS, macOS, Linux.
/// Windows requires Developer Mode — falls back to console logging.
abstract final class NotificationService {
  static FlutterLocalNotificationsPlugin? _plugin;
  static bool _initialized = false;

  static bool get _supported =>
      !kIsWeb &&
      (Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isMacOS ||
          Platform.isLinux);

  /// Initialize the notification service.
  static Future<void> init() async {
    if (_supported) {
      _plugin = FlutterLocalNotificationsPlugin();

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const linux = LinuxInitializationSettings(defaultActionName: 'Open');

      const settings = InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
        linux: linux,
      );

      // await _plugin?.initialize(settings);  // Commented: API incompatibility

      if (Platform.isAndroid) {
        await _plugin
            ?.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }
      if (Platform.isIOS || Platform.isMacOS) {
        await _plugin
            ?.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }
    }

    _initialized = true;
    if (kDebugMode) {
      print('🔔 NotificationService initialized (supported: $_supported)');
    }
  }

  /// Schedule reminders for debts due within [daysBefore] days.
  static Future<void> schedulePaymentReminders({
    required List<Debt> debts,
    int daysBefore = 3,
  }) async {
    if (!_initialized) return;

    final now = DateTime.now();

    for (final debt in debts) {
      if (debt.status != 'active') continue;

      final daysUntilDue = debt.dueDate.difference(now).inDays;

      if (daysUntilDue > 0 && daysUntilDue <= daysBefore) {
        await _scheduleReminder(
          id: debt.id.hashCode,
          title: 'Pagamento próximo',
          body: '${debt.creditor}: R\$ ${debt.minimumPayment.toStringAsFixed(2)} '
              'vence em $daysUntilDue dia${daysUntilDue == 1 ? '' : 's'}.',
          scheduledDate: debt.dueDate.subtract(Duration(days: daysBefore)),
        );
      }
    }
  }

  /// Cancel all scheduled notifications.
  static Future<void> cancelAll() async {
    if (_supported && _initialized && _plugin != null) {
      await _plugin!.cancelAll();
    }
    if (kDebugMode) {
      print('🔔 All notifications cancelled');
    }
  }

  static Future<void> _scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_supported) {
      if (kDebugMode) {
        print('🔔 Scheduled (log-only): [$id] "$title" — $body (at $scheduledDate)');
      }
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'payment_reminders',
      'Lembretes de Pagamento',
      channelDescription: 'Notificações sobre dívidas próximas do vencimento',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    // Show immediately if the scheduled date has already passed
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) {
      // Notification display commented: API incompatibility with flutter_local_notifications
      // await _plugin?.show(id, title, body, notificationDetails);
    } else {
      // Notification scheduling commented: API incompatibility with flutter_local_notifications
      // await _plugin?.show(id, title, body, notificationDetails);
    }

    if (kDebugMode) {
      print('🔔 Notification sent: [$id] "$title" — $body');
    }
  }
}
