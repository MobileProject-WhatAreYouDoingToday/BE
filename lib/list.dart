import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatareyoudoingtoday/MainWidget.dart';
import 'auth.dart';
import 'creation.dart';
import 'process.dart' as process;
import 'store.dart'; // Todo 클래스를 포함한 task.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoListPage extends StatefulWidget {
  final Auth auth;

  const TodoListPage({super.key, required this.auth});

  @override
  _TodoListPageState createState() => _TodoListPageState(auth);
}

class _TodoListPageState extends State<TodoListPage> {
  final Auth auth;

  List<Todo> tasks = []; // Todo 클래스를 사용하는 리스트
  List<bool> isMemoVisible = [];
  DateTime selectday = DateTime(0,0,0,0);
  Timestamp timestamp = Timestamp(0, 0);
  String email = "";

  _TodoListPageState(this.auth);

  @override
  void initState() {
    super.initState();
    email = auth.userCredential!.user!.email!;
    DateTime now = DateTime.now();
    selectday = DateTime(now.year, now.month, now.day);
    timestamp = Timestamp.fromDate(selectday);

    _loadTasks(); // 초기화 시 할 일 목록 로드
  }


  // Firestore에서 할 일 목록을 로드하는 메서드
  Future<void> _loadTasks() async {
    Store store = Store();
    List<Todo>? todoList = await store.getTodoList(email);

    print("todolist 크기 = ${todoList?.length}");

    if (todoList != null) {
      // tasks 리스트 초기화
      setState(() {
        tasks.clear(); // 기존의 tasks 리스트를 초기화
        isMemoVisible = List<bool>.filled(todoList.length, false).toList(); // 고정 길이 리스트를 가변 길이 리스트로 변환
      });

      for (int i = todoList.length-1; i >= 0; i--) {
        DateTime listDate = todoList[i].date.toDate();
        if (listDate.year == selectday.year &&
            listDate.month == selectday.month &&
            listDate.day == selectday.day) {
          _addTask(todoList[i]);
        }
      }
    }
  }


  void _prevDate() {
    setState(() {
      selectday = selectday.subtract(Duration(days: 1));
      timestamp = Timestamp.fromDate(selectday);
      tasks = [];
      _loadTasks(); // 초기화 시 할 일 목록 로드
    });
  }

  void _nextDate() {
    setState(() {
      selectday = selectday.add(Duration(days: 1));
      timestamp = Timestamp.fromDate(selectday);
      tasks = [];
      _loadTasks(); // 초기화 시 할 일 목록 로드
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
      print(task.name + '추가됨');
    });
  }

  void _navigateToCreationPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreationPage(email: email,)),
    );

    if (result != null && result['todo'] != null) {
      _addTask(result['todo']); // 생성된 Todo를 리스트에 추가
    }
  }

  void _navigateToProcessPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainWidget(auth: auth),
      ),
    );
  }

  void _removeTask(int index) {
    Store store = Store();
    store.removeTodo(email, tasks[index]); // Firestore에서 삭제하는 로직 추가
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
      Store().setTodo(email, tasks[index]);
      int incompleteTaskCount = tasks.where((task) => !task.is_completed).length;
      print('완료되지 않은 작업의 개수: $incompleteTaskCount');
      Store().setTodoPriority(email, tasks[index], incompleteTaskCount+tasks[index].priority);

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
                  DateFormat('yyyy.MM.dd').format(selectday),
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
                    key: ValueKey('${tasks[index].priority}_$index'), // 고유 키 설정
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 20),
                            GestureDetector(
                              onTap: () => {_toggleTaskPosition(index),
                              },// 체크 상태 토글 및 위치 조정
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