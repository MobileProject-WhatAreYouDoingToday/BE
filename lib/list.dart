import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'creation.dart';
import 'process.dart' as process;
import 'task.dart';

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  DateTime selectedDate = DateTime.now();
  List<Task> tasks = [];
  List<bool> isMemoVisible = [];

  @override
  void initState() {
    super.initState();
    isMemoVisible = [];
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
        isMemoVisible[index] = !isMemoVisible[index];
      }
    });
  }

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
      isMemoVisible.add(false);
    });
  }

  void _navigateToCreationPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreationPage()),
    );

    if (result is Task) {
      _addTask(result);
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
      orElse: () => Task(title: '모든 작업 완료', isCompleted: true),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('할 일 목록'),
        leading: IconButton(
          icon: Icon(Icons.check),
          onPressed: _navigateToProcessPage,
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
                  icon: Icon(Icons.chevron_left),
                  onPressed: _prevDate,
                ),
                Text(
                  DateFormat('yyyy.MM.dd').format(selectedDate),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: _nextDate,
                ),
              ],
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
                            icon: Icon(isMemoVisible[index]
                                ? Icons.remove
                                : Icons.add),
                            onPressed: () => _toggleMemoVisibility(index),
                          ),
                        ],
                      ),
                      if (isMemoVisible[index])
                        Text(
                          tasks[index].memo ?? '',
                          style: TextStyle(color: Colors.grey),
                        ),
                      SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: Icon(Icons.navigate_before), onPressed: () {}),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _navigateToCreationPage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
