import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }

    _initialized = true;
  }

  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String prayerName, // Parameter Baru: Untuk mengecek apakah ini Subuh
    required String status,     // Parameter Baru: 'audio' atau 'silent'
  }) async {
    if (!_initialized) await init();

    if (scheduledTime.isBefore(DateTime.now())) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    // LOGIKA PENENTUAN SALURAN (CHANNEL) & SUARA
    String channelId;
    String channelName;
    String channelDesc;
    bool playSound = status == 'audio';
    AndroidNotificationSound? sound;

    if (status == 'audio') {
      if (prayerName == 'Subuh') {
        channelId = 'adzan_subuh_alarm_channel';
        channelName = 'Adzan Subuh';
        channelDesc = 'Notifikasi dengan lafaz adzan Subuh';
        sound = const RawResourceAndroidNotificationSound('adzan_subuh');
      } else {
        channelId = 'adzan_standard_alarm_channel';
        channelName = 'Adzan Standar';
        channelDesc = 'Notifikasi dengan lafaz adzan standar';
        sound = const RawResourceAndroidNotificationSound('adzan');
      }
    } else {
      channelId = 'silent_alarm_channel';
      channelName = 'Notifikasi Senyap';
      channelDesc = 'Notifikasi getar tanpa suara';
      sound = null;
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: playSound,
      sound: sound,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
    );

    // Untuk iOS (Opsional, jika Anda mengembangkan ke iPhone nantinya)
    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
      sound: playSound 
          ? (prayerName == 'Subuh' ? 'adzan_subuh.aiff' : 'adzan.aiff') 
          : null,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}