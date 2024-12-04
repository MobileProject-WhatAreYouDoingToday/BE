import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatareyoudoingtoday/MainWidget.dart';
import 'auth.dart';
import 'creation.dart';
import 'store.dart'; // Todo 클래스를 포함한 task.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calendar.dart';

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
  DateTime selectday = DateTime(0,0,0);
  Timestamp timestamp = Timestamp(0, 0);
  String email = "";

  _TodoListPageState(this.auth);

  @override
  void initState() {
    super.initState();
    email = auth.userCredential!.user!.email!;
    DateTime now = DateTime.now();
    selectday = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    timestamp = Timestamp.fromDate(selectday);
    _loadTasks(); // 초기화 시 할 일 목록 로드
  }


  // Firestore에서 할 일 목록을 로드하는 메서드
  Future<void> _loadTasks() async {
    Store store = Store();
    List<Todo>? todoList = await store.getTodoList(email);

    print("todolist 크기 = ${todoList.length}");

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
    DateTime now = DateTime.now();
    setState(() {
      selectday = selectday.subtract(Duration(days: 1));
      DateTime saveDate = new DateTime(selectday.year,selectday.month,selectday.day,now.hour,now.minute);
      selectday = saveDate;
      print(selectday);
      timestamp = Timestamp.fromDate(selectday);
      tasks = [];
      _loadTasks(); // 초기화 시 할 일 목록 로드
    });
  }

  void _nextDate() {
    DateTime now = DateTime.now();
    setState(() {
      selectday = selectday.add(Duration(days: 1));
      DateTime saveDate = new DateTime(selectday.year,selectday.month,selectday.day,now.hour,now.minute);
      selectday = saveDate;
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
      MaterialPageRoute(builder: (context) => CreationPage(email: email, todo: null, selectDay: selectday)),
    );

    if (result != null && result['todo'] != null) {
      setState(() {
        tasks.insert(0,result['todo']); // 생성된 Todo를 리스트에 추가
        isMemoVisible.add(false);
      });

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
    if (newIndex > oldIndex) {
      newIndex--;
    }

    // 항목의 순서를 변경
    setState(() {
      final Todo task = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, task);
    });

    // 우선순위 재계산
    for (int i = 0; i < tasks.length; i++) {
      tasks[i].priority = tasks.length - i - 1;  // 우선순위를 내림차순으로 설정
    }

    // Firestore에 업데이트
    _updateTasksInFirestore();
  }


  void _toggleTaskPosition(int index) async {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;

      if (tasks[index].isCompleted) {
        // 완료된 항목을 리스트 맨 아래로 이동
        Todo completedTask = tasks.removeAt(index);
        tasks.add(completedTask);
      } else {
        // 미완료 항목을 리스트 맨 위로 이동
        Todo uncompletedTask = tasks.removeAt(index);
        tasks.insert(0, uncompletedTask);
      }

      // 우선순위 재계산
      for (int i = 0; i < tasks.length; i++) {
        tasks[i].priority = tasks.length - i - 1;
      }
    });

    // Firestore에 업데이트
    await _updateTasksInFirestore();
  }


  Future<void> _updateTasksInFirestore() async {
    try {
      for (var task in tasks) {
        await Store().setTodo(email, task);  // Firestore에 각 항목을 업데이트
      }
      print('모든 Todo 업데이트 성공');
    } catch (error) {
      print("Firestore 업데이트 중 오류 발생: $error");
    }
    await _loadTasks();
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
                GestureDetector(
                  onTap: () {
                    // calendar.dart 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CalendarPage(auth: auth)), // CalendarPage는 calendar.dart에 정의된 페이지입니다.
                    );
                  },
                  child: Text(
                    DateFormat('yyyy.MM.dd').format(selectday),
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
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
                    key: ValueKey('${tasks[index].date}_${tasks[index].name}'), // 고유 키로 date와 name 사용
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
                                tasks[index].isCompleted
                                    ? 'assets/images/checkbox.png'
                                    : 'assets/images/uncheckbox.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => CreationPage(email: email, todo: tasks[index], selectDay: tasks[index].date.toDate(),),));
                                },
                                child: Text(
                                  tasks[index].name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            )
                            ,
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
                    'assets/images/chartBig.png',
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