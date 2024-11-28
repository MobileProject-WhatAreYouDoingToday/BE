import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'auth.dart';
import 'list.dart';

class MainWidget extends StatelessWidget {
  final Auth auth;

  const MainWidget({required this.auth});

  @override
  Widget build(BuildContext context) {
    Timestamp timestamp = timestamp(new Date)
    double progressValue = 0.8; //진행상태
    int progressPercentage = (progressValue * 100).round(); //퍼센트로 변환
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
                  MaterialPageRoute(builder: (context) => TodoListPage()),
                );
              },
              child: Container(
                width: 60.0,
                height: 60.0,
                child: Image.asset("assets/images/todolist.png"),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 25.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TodoListPage()),
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
            formattedDate,  // 오늘 날짜와 시간이 자동으로 표시됩니다
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
            progressValue == 1.0 ? '모두 달성했어요!': '아직 달성하지 못했어요!',
            style: TextStyle(
              fontSize: 18,
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
                Checkbox(value: false, onChanged: (value) {}),
                SizedBox(width: 10),
                Text(
                  '미용실 가기',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
