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

  @override
  Widget build(BuildContext context) {
    DateTime selectingTime = selectedTime;
    DateTime saveDate = new DateTime(selectedTime.year,selectedTime.month,selectedTime.day);

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
                  isForce2Digits: true,
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
            SizedBox(height: 50),
            // 저장 버튼
            GestureDetector(
              onTap: () {
                setState(() {
                  selectingTime = new DateTime(saveDate.year,saveDate.month,saveDate.day,selectingTime.hour,selectingTime.minute);
                });
                print("저장할 시간 ${selectingTime}");
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
}