import 'package:flutter/material.dart';
import 'task.dart'; // list.dart 파일을 불러옵니다.
import 'list.dart';

class ProcessScreen extends StatelessWidget {
  final List<Task> tasks; // Task 모델은 체크리스트 항목을 나타냅니다.

  ProcessScreen({required this.tasks});

  @override
  Widget build(BuildContext context) {
    int totalTasks = tasks.length;
    int completedTasks = tasks.where((task) => task.isCompleted).length;
    double achievementRate =
        totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0;

    // 체크되지 않은 항목 중 첫 번째 항목 찾기
    Task? nextTask = tasks.firstWhere(
      (task) => !task.isCompleted,
      orElse: () => Task(title: '', isCompleted: false), // 기본값 제공
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('오늘의 달성률'),
        leading: IconButton(
          icon: Icon(Icons.list),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TodoListPage()), // list.dart로 이동
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 달성률 원형 그래프
            CircularProgressIndicator(
              value: achievementRate / 100,
              strokeWidth: 10,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            SizedBox(height: 20),
            Text(
              '${achievementRate.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // 체크 완료되지 않은 항목 표시
            if (nextTask.title.isNotEmpty) ...[
              Text(
                '아직 달성 하지 못했어요!',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: nextTask.isCompleted,
                    onChanged: (bool? value) {
                      // 체크박스 클릭 시 처리 로직 추가
                    },
                  ),
                  Text(nextTask.title), // 항목 제목
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Task 모델 클래스
class Task {
  final String title;
  bool isCompleted;

  Task({required this.title, this.isCompleted = false});
}
