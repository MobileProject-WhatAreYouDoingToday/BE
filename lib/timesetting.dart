import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'creation.dart'; // creation.dart 파일을 불러옵니다.

class TimeSetting extends StatefulWidget {
  @override
  _TimeSettingState createState() => _TimeSettingState();
}

class _TimeSettingState extends State<TimeSetting> {
  DateTime selectedTime = DateTime.now();
  int? reminderTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('시간 설정'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreationPage()), // creation.dart로 이동
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 시간 선택기
            TimePickerSpinner(
              time: selectedTime,
              is24HourMode: true,
              onTimeChange: (time) {
                setState(() {
                  selectedTime = time; // 선택한 시간 저장
                });
              },
            ),
            SizedBox(height: 20),
            // 선택한 시간 표시
            Text(
              '선택한 시간: ${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            // 알림 설정
            Text('시작 전', style: TextStyle(fontSize: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setReminder(5),
                  child: Text('5분'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return reminderTime == 5 ? Colors.orange : null;
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => setReminder(10),
                  child: Text('10분'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return reminderTime == 10 ? Colors.orange : null;
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => setReminder(30),
                  child: Text('30분'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return reminderTime == 30 ? Colors.orange : null;
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 저장 버튼 클릭 시 처리
                // 여기에 저장 로직 추가
                print('저장된 시간: ${selectedTime.hour}:${selectedTime.minute}');
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void setReminder(int minutes) {
    setState(() {
      reminderTime = minutes;
    });
  }
}
