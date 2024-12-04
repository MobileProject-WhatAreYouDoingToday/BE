import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'store.dart'; // Todo 클래스를 포함한 Store 관련 파일
import 'creation.dart';

class TimeSetting extends StatefulWidget {
  @override
  _TimeSettingState createState() => _TimeSettingState();
}

class _TimeSettingState extends State<TimeSetting> {
  DateTime selectedTime = DateTime.now(); // 선택한 시간
  int? reminderTime; // 알림 시간 (분 단위)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 완전히 흰색으로 설정
      appBar:AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('시간설정'),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimePicker(),
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // AppBar 구성
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Center(
        child: Text(
          '시간 설정',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.black,
          ),
        ),
      ),
      leading: IconButton(
        padding: EdgeInsets.only(left: 9.0),
        icon: Image.asset(
          'assets/images/leftIcon.png',
          width: 70,
          height: 70,
        ),
        onPressed: () {
          Navigator.pop(context); // 이전 화면으로 돌아가기
        },
      ),
    );
  }

  // 시간 선택기 구성
  Widget _buildTimePicker() {
    return Container(
      height: 400,
      width: 200,
      child: FittedBox(
        child: TimePickerSpinner(
          time: selectedTime,
          is24HourMode: true,
          onTimeChange: (time) {
            setState(() {
              selectedTime = time; // 선택한 시간 업데이트
            });
          },
          normalTextStyle: TextStyle(
            fontSize: 30,
            color: Colors.grey,
          ),
          highlightedTextStyle: TextStyle(
            fontSize: 30,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // 저장 버튼 구성
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saveTodo,
      child: Container(
        width: 400,
        height: 70,
        child: Image.asset("assets/images/savebtn.png"), // 저장 버튼 이미지
      ),
    );
  }

  // 알림 버튼 구성
  Widget _buildReminderButton(int minutes, String imagePath, String selectedImagePath) {
    return InkWell(
      onTap: () => _setReminder(minutes), // 알림 시간 설정
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            reminderTime == minutes ? selectedImagePath : imagePath, // 선택된 이미지 사용
            width: 70.0,
            height: 50.0,
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  // 알림 시간 설정
  void _setReminder(int minutes) {
    setState(() {
      reminderTime = minutes;
    });
  }

  // Todo 저장 로직
  void _saveTodo() {
    // Todo 객체 생성
    Todo newTodo = Todo(
      name: '새로운 할 일',
      categori: '기타',
      date: Timestamp.now(),
      isNotification: true,
      priority: 0,
      is_completed: false,
      description: '선택한 시간: ${selectedTime.hour}:${selectedTime.minute}, 알림 시간: ${reminderTime ?? 0} 분',
    );

    // Firestore에 저장
    FirebaseFirestore.instance.collection('todos').add(newTodo.toFirestore()).then((_) {
      // 이전 화면으로 반환
      Navigator.pop(context, {
        'todo': newTodo,
        'selectedTime': TimeOfDay.fromDateTime(selectedTime),
        'reminderTime': reminderTime,
      });
    }).catchError((error) {
      print('저장 실패: $error');
    });
  }
}
