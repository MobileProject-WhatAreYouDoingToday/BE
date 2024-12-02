import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'creation.dart';
import 'process.dart' as process;
import 'store.dart'; // Todo 클래스를 포함한 task.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  DateTime selectedDate = DateTime.now();
  List<Todo> tasks = []; // Todo 클래스를 사용하는 리스트
  List<bool> isMemoVisible = [];

  @override
  void initState() {
    super.initState();
    _loadTasks(); // 초기화 시 할 일 목록 로드
  }

  // Firestore에서 할 일 목록을 로드하는 메서드
  Future<void> _loadTasks() async {
    String email = "2171322@hansung.ac.kr"; // 예시: 이메일을 사용자 이메일로 대체
    Store store = Store();
    List<Todo>? todoList = await store.getTodoList(email);
    if (todoList != null) {
      setState(() {
        tasks = todoList;
        isMemoVisible = List<bool>.filled(tasks.length, false); // tasks의 길이에 맞게 초기화
      });
    }
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

  void _addTask(Todo task) {
    setState(() {
      tasks.add(task);
      isMemoVisible.add(false);
      // Firestore에 추가하는 로직 추가
      String email = "2171322@hansung.ac.kr"; // 이메일을 사용자 이메일로 대체
      Store store = Store();
      store.setTodo(email, task);
    });
  }

  void _navigateToCreationPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreationPage()),
    );

    if (result != null && result['todo'] != null) {
      _addTask(result['todo']); // 생성된 Todo를 리스트에 추가
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

  void _removeTask(int index) {
    String email = "user@example.com"; // 이메일을 사용자 이메일로 대체
    Store store = Store();
    store.setTodo(email, tasks[index]); // Firestore에서 삭제하는 로직 추가
    setState(() {
      tasks.removeAt(index);
      isMemoVisible.removeAt(index);
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--; // 드래그 시 인덱스 조정
      final Todo task = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, task);
      // Firestore에서 순서 변경 로직 추가 필요
    });
  }

  void _toggleTaskPosition(int index) {
    setState(() {
      tasks[index].is_completed = !tasks[index].is_completed;

      // 체크된 상태일 경우, 해당 항목을 리스트의 맨 아래로 이동
      if (tasks[index].is_completed) {
        Todo completedTask = tasks.removeAt(index);
        tasks.add(completedTask);
      }
      // 체크 해제된 항목은 리스트 상단으로 올라오도록 재정렬
      tasks.sort((a, b) {
        return a.is_completed ? 1 : -1; // 미완료 항목이 먼저 오도록 정렬
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: null,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _prevDate,
                  child: Image.asset(
                    'assets/images/leftIcon.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                SizedBox(width: 50),
                Text(
                  DateFormat('yyyy.MM.dd').format(selectedDate),
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 50),
                GestureDetector(
                  onTap: _nextDate,
                  child: Image.asset(
                    'assets/images/rightIcon.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: tasks.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(tasks[index].name),
                    background: Container(
                      color: Color(0x80FC0404),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Image.asset(
                            'assets/images/trash.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _removeTask(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${tasks[index].name}이(가) 삭제되었습니다.'),
                        ),
                      );
                    },
                    child: Column(
                      key: ValueKey(tasks[index].name), // 고유 키 설정
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 20),
                            GestureDetector(
                              onTap: () => _toggleTaskPosition(index), // 체크 상태 토글 및 위치 조정
                              child: Image.asset(
                                tasks[index].is_completed
                                    ? 'assets/images/checkbox.png'
                                    : 'assets/images/uncheckbox.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                tasks[index].name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _toggleMemoVisibility(index),
                              child: Image.asset(
                                isMemoVisible.length > index && isMemoVisible[index]
                                    ? 'assets/images/upbtn.png'
                                    : 'assets/images/downbtn.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                            SizedBox(width: 20),
                          ],
                        ),
                        if (isMemoVisible.length > index && isMemoVisible[index])
                          Padding(
                            padding: const EdgeInsets.only(left: 60.0, top: 8.0),
                            child: Container(
                              width: 295,
                              decoration: BoxDecoration(
                                color: Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                tasks[index].description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _navigateToProcessPage,
                  child: Image.asset(
                    'assets/images/chart.png',
                    width: 80,
                    height: 80,
                  ),
                ),
                GestureDetector(
                  onTap: _navigateToCreationPage,
                  child: Image.asset(
                    'assets/images/addIcon.png',
                    width: 80,
                    height: 80,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}