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
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  String email = "";
  List<Todo> todoList = [];
  late double progressValue = 0.0;
  late int progressPercentage = 0;
  Store store = Store();

  @override
  void initState() {
    super.initState();
    email = widget.auth.userCredential!.user!.email!;
    getTodoList();
  }

  Future<void> getTodoList() async {
    todoList = (await store.getTodoList(email))!;


    setState(() {
      if (todoList == null || todoList!.isEmpty) {
        // Todo nullTodo = new Todo(name: "아직 할 일이 없습니다.", categori: "null", date: Timestamp.fromDate(DateTime.now()),
        //     isNotification: false, priority: 0, is_completed: false, description: "");
        // todoList!.add(nullTodo);
        progressValue = 0.0;
        progressPercentage = (progressValue * 100).round(); // 퍼센트로 변환
      } else {
        int checked = 0;
        for(int i=0;i<todoList.length;i++){
          if(todoList[i].is_completed){
            checked++;
          }
        }
        progressValue = checked/todoList.length;
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
                  MaterialPageRoute(builder: (context) => LoginWidget()),
                );
              },
              child: Container(
                width: 60.0,
                height: 60.0,
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
                      MaterialPageRoute(builder: (context) => CalendarPage()),
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
            // timestamp as String,  // 오늘 날짜와 시간이 자동으로 표시됩니다
            formattedDate,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            '오늘의 달성률',
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30),
          // Circular Progress Indicator (Custom design for 65%)
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
                          color: Color.fromRGBO(0, 0, 0, 0.7),  // 70% 투명도 검은색
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
            child: Row(
              children: [
                todoList.isNotEmpty ?
                Checkbox(value: todoList[0].is_completed, onChanged: (value) {
                  todoList[0].is_completed = true;
                  store.setTodo(email, todoList[0]);
                }) : Checkbox(value: false, onChanged: null,),
                SizedBox(width: 10),
                Text(
                  todoList.isNotEmpty ? todoList[0].name : "오늘 할 일이 없습니다.",
                  style: TextStyle(fontSize: 16, color: todoList.isNotEmpty ? Colors.black : Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}