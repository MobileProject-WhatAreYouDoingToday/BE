import 'package:crypto/crypto.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:TodayTodo/store.dart';
import 'dart:convert'; // todo id 정수로 치환하기 위해
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
    // todo id int로 바꿔버리기
    var bytes = utf8.encode(todo.id!);
    var digest = sha1.convert(bytes);
    int uid = int.parse(digest.toString().substring(0, 8), radix: 16) % 2147483647;

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

      try { // 이미 설정된 알람일 경우 삭제하고 다시 추가하도록
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
        androidScheduleMode: AndroidScheduleMode.exact, // 즉시 알람 가려면 inexact 쓰면 안 됨
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
