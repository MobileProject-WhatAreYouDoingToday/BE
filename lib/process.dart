import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'store.dart'; // Todo 클래스를 포함한 task.dart
import 'list.dart';

class ProcessScreen extends StatelessWidget {
  final List<Todo> tasks; // Todo 모델은 체크리스트 항목을 나타냅니다.

  ProcessScreen({required this.tasks});

  @override
  Widget build(BuildContext context) {
    int totalTasks = tasks.length;
    int completedTasks = tasks.where((todo) => todo.is_completed).length; // is_completed 필드 사용
    double achievementRate =
    totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0;

    // 체크되지 않은 항목 중 첫 번째 항목 찾기
    Todo? nextTask = tasks.firstWhere(
          (todo) => !todo.is_completed,
      orElse: () => Todo(
        name: '',
        categori: '',
        date: Timestamp.now(),
        isNotification: false,
        priority: 0,
        is_completed: false,
        description: '',
        //task: null,
      ), // 기본값 제공
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
                builder: (context) => TodoListPage(), // list.dart로 이동
              ),
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
            if (nextTask.name.isNotEmpty) ...[
              Text(
                '아직 달성하지 못했어요!',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: nextTask.is_completed,
                    onChanged: (bool? value) {
                      // 체크박스 클릭 시 처리 로직 추가
                    },
                  ),
                  Text(nextTask.name), // 항목 제목
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}