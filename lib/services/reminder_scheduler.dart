import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/date_keys.dart';
import '../models/models.dart';

/// Giao diện đặt lịch nhắc việc. Nếu muốn đổi thư viện thông báo,
/// chỉ cần viết lớp mới cài đặt giao diện này.
abstract class ReminderScheduler {
  Future<bool> ensurePermission();
  Future<void> schedule(Reminder reminder);
  Future<void> cancel(int reminderId);
}

class LocalReminderScheduler implements ReminderScheduler {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()));
    } catch (_) {}
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    await _plugin.initialize(settings);
  }

  @override
  Future<bool> ensurePermission() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  @override
  Future<void> cancel(int reminderId) => _plugin.cancel(reminderId);

  @override
  Future<void> schedule(Reminder r) async {
    final id = r.id;
    if (id == null) return;
    await _plugin.cancel(id);
    if (!r.enabled) return;

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime when;
    DateTimeComponents? match;

    switch (r.repeat) {
      case RepeatKind.once:
        final d = parseDateKey(r.date);
        when = tz.TZDateTime(tz.local, d.year, d.month, d.day, r.hour, r.minute);
        if (when.isBefore(now)) return;
        break;
      case RepeatKind.daily:
        when = tz.TZDateTime(tz.local, now.year, now.month, now.day, r.hour, r.minute);
        if (when.isBefore(now)) when = when.add(const Duration(days: 1));
        match = DateTimeComponents.time;
        break;
      case RepeatKind.weekly:
        when = tz.TZDateTime(tz.local, now.year, now.month, now.day, r.hour, r.minute);
        while (when.weekday != r.weekday || when.isBefore(now)) {
          when = when.add(const Duration(days: 1));
        }
        match = DateTimeComponents.dayOfWeekAndTime;
        break;
    }

    await _plugin.zonedSchedule(
      id,
      '${r.emoji} ${r.title}',
      'Đến giờ học rồi bé ơi! 🎉',
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails('hoc_tap', 'Nhắc học tập',
            importance: Importance.max, priority: Priority.high),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true, presentBadge: true),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: match,
    );
  }
}
