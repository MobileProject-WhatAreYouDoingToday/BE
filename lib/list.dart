import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'creation.dart'; // creation.dart 파일을 임포트합니다.
import 'process.dart' as process; // process.dart를 접두사와 함께 임포트합니다.
import 'task.dart'; // Task 모델을 임포트합니다.

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  DateTime selectedDate = DateTime.now();
  List<Task> tasks = []; // Task 모델 리스트로 변경
  List<bool> isMemoVisible = []; // 각 할 일의 메모 표시 상태

  @override
  void initState() {
    super.initState();
    // isMemoVisible 리스트 초기화
    isMemoVisible = List<bool>.filled(tasks.length, false); // 수정된 부분
  }

  void _prevDate() {
    setState(() {
      selectedDate = selectedDate.subtract(Duration(days: 1));
    });
  }

  void _nextDate() {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: 1));
    });
  }

  void _toggleMemoVisibility(int index) {
    setState(() {
      if (index < isMemoVisible.length) {
        isMemoVisible[index] = !isMemoVisible[index]; // 특정 인덱스의 메모 열기/닫기 상태 토글
      }
    });
  }

  void _navigateToCreationPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreationPage()),
    );

    if (result is Task) {
      setState(() {
        tasks.add(result); // Task 객체 추가
        isMemoVisible.add(false); // 새로운 작업 추가 시 메모 표시 상태 초기화
      });
    }
  }

  void _navigateToProcessPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => process.ProcessScreen(tasks: tasks),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalTasks = tasks.length;
    int completedTasks = tasks.where((task) => task.isCompleted).length;
    double achievementRate =
        totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0;

    Task? nextTask = tasks.firstWhere(
      (task) => !task.isCompleted,
      orElse: () => Task(title: '모든 항목이 완료되었습니다.'), // 기본값 제공
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('할 일 목록'),
        leading: IconButton(
          icon: Icon(Icons.check), // 체크 아이콘
          onPressed: _navigateToProcessPage, // ProcessScreen으로 이동
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: Icon(Icons.chevron_left), onPressed: _prevDate),
                Text(DateFormat('yyyy.MM.dd').format(selectedDate),
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(
                    icon: Icon(Icons.chevron_right), onPressed: _nextDate),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '달성률: ${achievementRate.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tasks[index].title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: tasks[index].isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(isMemoVisible.length > index &&
                                    isMemoVisible[index]
                                ? Icons.remove
                                : Icons.add),
                            onPressed: () => _toggleMemoVisibility(index),
                          ),
                        ],
                      ),
                      if (isMemoVisible.length > index && isMemoVisible[index])
                        Text(tasks[index].memo ?? '',
                            style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 10), // 간격 조정
                    ],
                  );
                },
              ),
            ),
            if (nextTask != null) ...[
              Text(
                '아직 달성하지 못한 항목:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(nextTask.title, style: TextStyle(color: Colors.red)),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: Icon(Icons.navigate_before), onPressed: () {}),
                IconButton(
                  icon: Icon(Icons.add), // 오른쪽 버튼 아이콘
                  onPressed: _navigateToCreationPage, // CreationPage로 이동
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
