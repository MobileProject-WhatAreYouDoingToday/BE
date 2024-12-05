import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:TodayTodo/store.dart';
import 'dart:convert'; // for the utf8.encode method
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart'; // 파이어베이스 패키지
import 'package:flutter/material.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._();

  NotificationService._();
  factory NotificationService() {
    return _instance;
  }

  final FlutterLocalNotificationsPlugin _notificationPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/logo'); // 아이콘 경로 수정

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notificationPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification(Todo todo) async {
    var bytes = utf8.encode(todo.id!); // 문자열을 바이트로 변환
    var digest = sha1.convert(bytes); // SHA1 해시 생성
    int uid = int.parse(digest.toString().substring(0, 8), radix: 16) % 2147483647; // 32비트 정수 범위 내로 조정

    if (todo.isNotification == true) {
      tz.initializeTimeZones();
      DateTime todoDate = todo.date.toDate();
      DateTime totime = new DateTime(todoDate.year, todoDate.month, todoDate.day, todoDate.hour, todoDate.minute,0,0);
      tz.TZDateTime date = tz.TZDateTime.from(totime, tz.local);

      var androidDetails = AndroidNotificationDetails(
        'your_channel_id',
        '리마인더',
        priority: Priority.high,
        importance: Importance.max,
      );

      try {
        await _instance._notificationPlugin.cancel(uid);
        print("삭제성공");
      } catch (e) {
      }
      await _instance._notificationPlugin.zonedSchedule(
        uid,
        "오늘 뭐해?",
        "${todo.name} 할 시간입니다.",
        date,
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      print("푸시 알림 생성");
    } else {
      try {
        await _instance._notificationPlugin.cancel(uid);
        print("삭제성공");
      } catch (e) {
      }
    }
  }
}
