import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:whatareyoudoingtoday/store.dart';
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
      tz.TZDateTime date = tz.TZDateTime.from(todo.date.toDate(), tz.local);

      var androidDetails = AndroidNotificationDetails(
        'your_channel_id', // 채널 ID 수정
        '리마인더', // 채널 이름
        priority: Priority.high,
        importance: Importance.max,
      );

      await _instance._notificationPlugin.zonedSchedule(
        uid,
        todo.name,
        todo.description,
        date,
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.inexact, // 일반 알람 모드 사용
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      print("푸시 알림 생성");
    } else {
      try {
        await _instance._notificationPlugin.cancel(uid);
      } catch (e) {
        return;
      }
    }
  }
}
