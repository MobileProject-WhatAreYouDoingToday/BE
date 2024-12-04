import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'store.dart'; // Todo 클래스를 포함한 task.dart
import 'creation.dart';

class TimeSetting extends StatefulWidget {
  final DateTime selectedTime;

  const TimeSetting({super.key, required this.selectedTime});
  @override
  _TimeSettingState createState() => _TimeSettingState(selectedTime);
}

class _TimeSettingState extends State<TimeSetting> {
  final DateTime selectedTime;

  _TimeSettingState(this.selectedTime);
  int? reminderTime;

  @override
  Widget build(BuildContext context) {
    DateTime selectingTime = selectedTime;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(right: 55.0), // 왼쪽 패딩 추가
          child: Text(
            '시간 설정',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ),
        leading: IconButton(
          padding: EdgeInsets.only(left: 9.0), // 왼쪽 패딩 추가
          icon: Image.asset(
            'assets/images/leftIcon.png', // PNG 파일 경로
            width: 70, // 원하는 너비
            height: 70, // 원하는 높이
          ),
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 돌아가기
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 시간 선택기
            Container(
              height: 400, // 원하는 높이 설정
              width: 200, // 원하는 너비 설정
              child: FittedBox(
                child: TimePickerSpinner(
                  time: selectedTime,
                  is24HourMode: true,
                  onTimeChange: (time) {
                    selectingTime = time; // 선택한 시간 저장
                    print("바꾼 시간 ${selectingTime}");
                  },
                  normalTextStyle: TextStyle(
                    fontSize: 30, // 일반 텍스트 크기
                    color: Colors.grey,
                  ),
                  highlightedTextStyle: TextStyle(
                    fontSize: 30, // 강조된 텍스트 크기
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '시작 전',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold, // 텍스트를 굵게 설정
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10), // Text와 버튼 사이의 간격
                _buildReminderButton(
                    5,
                    'assets/images/5minute.png',
                    'assets/images/5min.png' // 선택된 이미지 경로
                ), // 5분 버튼
                SizedBox(width: 10),
                _buildReminderButton(
                    10,
                    'assets/images/10minute.png',
                    'assets/images/10min.png' // 선택된 이미지 경로
                ), // 10분 버튼
                SizedBox(width: 10),
                _buildReminderButton(
                    30,
                    'assets/images/30minute.png',
                    'assets/images/30min.png' // 선택된 이미지 경로
                ), // 30분 버튼
              ],
            ),
            SizedBox(height: 50),
            // 저장 버튼
            GestureDetector(
              onTap: () {
                Navigator.pop(context, selectingTime); // TimeSetting으로 selectedTime 반환
              },
              child: Container(
                width: 400,
                height: 70,
                child: Image.asset("assets/images/savebtn.png"), // 저장 버튼 이미지 경로
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderButton(int minutes, String imagePath, String selectedImagePath) {
    return InkWell(
      onTap: () => setReminder(minutes, selectedImagePath), // 클릭 시 알림 시간 설정
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            reminderTime == minutes ? selectedImagePath : imagePath, // 선택된 이미지 사용
            width: 70.0, // 원하는 너비
            height: 50.0, // 원하는 높이 (조정 가능)
          ),
          SizedBox(height: 5), // 아이콘과 텍스트 사이의 간격
        ],
      ),
    );
  }

  void setReminder(int minutes, String imagePath) {
    setState(() {
      reminderTime = minutes; // 알림 시간 설정
    });
  }
}