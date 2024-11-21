import 'package:flutter/material.dart';
import 'timesetting.dart'; // 시간 설정 화면을 위한 파일 임포트
import 'task.dart';

class CreationPage extends StatefulWidget {
  @override
  _CreationPageState createState() => _CreationPageState();
}

class _CreationPageState extends State<CreationPage> {
  String taskTitle = '';
  String taskMemo = '';
  bool isNotificationOn = false;
  TimeOfDay selectedTime = TimeOfDay.now();
  int? selectedCategory; // nullable 변수

  void _saveTask() {
    if (taskTitle.isNotEmpty) {
      // Task 객체 생성
      Task newTask = Task(
        title: taskTitle,
        memo: taskMemo,
      );
      // Task 객체를 반환
      Navigator.pop(context, newTask);
    } else {
      // 제목이 비어있을 경우 경고 표시 (옵션)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('할 일 제목을 입력해주세요.')),
      );
    }
  }

  void _goBack() {
    Navigator.pop(context);
  }

  // 알림 시간 설정 페이지로 이동
  void _navigateToTimeSetting() async {
    final TimeOfDay? result = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (result != null) {
      setState(() {
        selectedTime = result; // 선택된 시간으로 업데이트
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('할 일 생성 및 수정'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: _goBack,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.yellow),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('할 일 제목을 입력해주세요', style: TextStyle(fontSize: 18)),
            TextField(
              onChanged: (value) {
                setState(() {
                  taskTitle = value;
                });
              },
              decoration: InputDecoration(hintText: '할 일 제목'),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _navigateToTimeSetting, // 알림 시간 영역 클릭 시 시간 설정
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('알림 시간: ${selectedTime.format(context)}',
                        style: TextStyle(fontSize: 18)),
                    Switch(
                      value: isNotificationOn,
                      onChanged: (value) {
                        setState(() {
                          isNotificationOn = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('카테고리를 선택해주세요', style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 8.0,
              children: [
                _buildCategoryButton(0, '헬스', Colors.orange),
                _buildCategoryButton(1, '독서', Colors.teal),
                _buildCategoryButton(2, '작성', Colors.purple),
                _buildCategoryButton(3, '기타', Colors.blue),
              ],
            ),
            SizedBox(height: 20),
            Text('할 일을 적어주세요', style: TextStyle(fontSize: 18)),
            TextField(
              maxLines: 4,
              onChanged: (value) {
                setState(() {
                  taskMemo = value;
                });
              },
              decoration: InputDecoration(hintText: '할 일 메모'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(int index, String label, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = index;
        });
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selectedCategory == index ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label),
      ),
    );
  }
}
