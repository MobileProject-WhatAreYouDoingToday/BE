import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatareyoudoingtoday/store.dart';

import 'auth.dart';
import 'calendar.dart';
import 'list.dart';

class MainWidget extends StatefulWidget {
  final Auth auth;

  MainWidget({required this.auth});

  @override
  _MainWidgetState createState() => _MainWidgetState(auth);
}

class _MainWidgetState extends State<MainWidget> {
  final Auth auth;
  String email = "";
  List<Todo> todoList = [];
  late double progressValue = 0.0;
  late int progressPercentage = 0;
  Store store = Store();

  _MainWidgetState(this.auth);

  @override
  void initState() {
    super.initState();
    email = widget.auth.userCredential!.user!.email!;
    getTodoList();
  }

  Future<void> getTodoList() async {
    todoList = (await store.getTodoList(email))!;

    setState(() {
      if (todoList == null || todoList.isEmpty) {
        progressValue = 0.0;
        progressPercentage = (progressValue * 100).round(); // 퍼센트로 변환
      } else {
        todoList.sort((a, b) => a.priority.compareTo(b.priority));

        int checked = 0;
        for (int i = 0; i < todoList.length; i++) {
          if (todoList[i].is_completed) {
            checked++;
          }
        }
        progressValue = checked / todoList.length;
        progressPercentage = (progressValue * 100).round(); // 퍼센트로 변환
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    Timestamp timestamp = Timestamp.fromDate(today);

    String formattedDate = DateFormat('MMMM dd, EEEE').format(DateTime.now());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(125.0),
        child: Padding(
          padding: EdgeInsets.only(left: 25.0, top: 40.0),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TodoListPage(auth: auth)),
                );
              },
              child: Container(
                width: 70.0,
                height: 70.0,
                child: Image.asset("assets/images/todobutton.png"),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 25.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CalendarPage(auth: auth)),
                    );
                  },
                  child: Container(
                    width: 60.0,
                    height: 60.0,
                    child: Image.asset("assets/images/calender.png"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formattedDate,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            '오늘의 달성률',
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30),
          // Circular Progress Indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 외부 원 (배경)
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color.fromRGBO(0, 0, 0, 0.7), // 70% 투명도 검은색
                          width: 70, // 윤곽선 두께
                        ),
                      ),
                    ),
                    // 원형 로딩 인디케이터
                    Container(
                      width: 190,
                      height: 190,
                      child: CircularProgressIndicator(
                        strokeWidth: 65, // 로딩 인디케이터 두께
                        valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(249, 90, 44, 0.75)),
                        backgroundColor: Colors.grey.shade300,
                        value: progressValue, // 현재 진행 상태 (0.0 - 1.0)
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$progressPercentage',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
          Text(
            progressValue == 1.0 ? '모두 달성했어요!' : '아직 달성하지 못했어요!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          Spacer(),
          Container(
            color: Colors.grey.shade200,
            padding: EdgeInsets.all(25),
            height: 70, // 고정 높이 설정
            child: todoList.isNotEmpty && !todoList.every((todo) => todo.is_completed)
                ? Row(
                children: [
                  // 체크박스가 체크된 상태를 나타내는 이미지
                  GestureDetector(
                    onTap: () async {
                      if (todoList.isNotEmpty) {
                        setState(() {
                          // 체크 상태를 변경
                          todoList[0].is_completed = !todoList[0].is_completed;
                        });
                        // Firestore에 업데이트
                        await store.setTodo(email, todoList[0]);
                        // 체크 상태를 변경한 후 진행률 업데이트
                        await getTodoList();
                      }
                    },
                    child: Image.asset(
                      todoList[0].is_completed
                          ? 'assets/images/checkbox.png' // 체크된 상태 이미지
                          : 'assets/images/uncheckbox.png', // 체크 해제 상태 이미지
                      width: 30,
                      height: 30,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    todoList[0].name,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ]
            )
                : Container(), // 모든 항목이 완료된 경우 빈 컨테이너 반환
          ),
        ],
      ),
    );
  }
}