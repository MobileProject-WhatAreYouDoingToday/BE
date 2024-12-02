import 'package:flutter/material.dart';
import 'auth.dart';
import 'timesetting.dart'; // 시간 설정 화면을 위한 파일 임포트
import 'package:cloud_firestore/cloud_firestore.dart';
import 'store.dart'; // Todo 클래스를 포함한 task.dart
import 'notification_service.dart';

class CreationPage extends StatefulWidget {
  final String email;

  const CreationPage({super.key, required this.email});

  @override
  _CreationPageState createState() => _CreationPageState(email);
}

class _CreationPageState extends State<CreationPage> {
  final String email;
  String taskTitle = '';
  String taskMemo = '';
  bool isNotificationOn = false;
  TimeOfDay selectedTime = TimeOfDay.now();
  int? selectedCategory; // nullable 변수
  int? reminderTime;

  _CreationPageState(this.email); // 알림 시간 변수 추가

  void _saveTask() {
    if (taskTitle.isNotEmpty) {
      // Todo 객체 생성
      Todo newTodo = Todo(
        name: taskTitle,
        categori: selectedCategory != null ? selectedCategory.toString() : '기타', // 카테고리 설정
        date: Timestamp.now(), // 현재 시간으로 설정
        isNotification: isNotificationOn, // 알림 여부 설정
        priority: 0, // 기본 우선순위
        is_completed: false, // 기본 완료 상태
        description: taskMemo,
        //task: null, // Task 필드에 적절한 값을 할당 (현재 Task 객체가 없으므로 null)
      );
      if (isNotificationOn) {
        // 현재 시간과 선택된 시간의 차이를 계산
        final now = TimeOfDay.now();
        final notificationTime = selectedTime.hour * 60 + selectedTime.minute;
        final currentTime = now.hour * 60 + now.minute;

        final difference = notificationTime - currentTime;
        if (difference > 0) {
          // 알림 예약 (예: difference 분 후에 알림 울리게 설정)
          Future.delayed(Duration(minutes: difference), () {
            NotificationService.showNotification('할 일 알림', '할 일이 있습니다: $taskTitle');
          });
        } else {
          // 선택된 시간이 이미 지났다면 즉시 알림
          NotificationService.showNotification('할 일 알림', '할 일이 있습니다: $taskTitle');
        }
      }
      print(newTodo.date);
      Store().getSelectedDateTodoList(email, newTodo.date);
      // Todo 객체를 반환
      Navigator.pop(context, {'todo': newTodo, 'selectedTime': selectedTime, 'reminderTime': reminderTime});
      Store().setTodo(email, newTodo);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('할 일 제목을 입력해주세요.')),
      );
    }
  }

  void _goBack() {
    Navigator.pop(context);
  }

  // 알림 시간 설정 페이지로 이동
  void _navigateToTimeSetting() async {
    // TimeSetting 페이지로 이동
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TimeSetting()),
    );

    // 반환된 데이터 처리
    if (result != null) {
      final newTodo = result['todo'] as Todo; // Todo 객체
      final TimeOfDay selectedTime = result['selectedTime']; // 선택된 시간
      final int? reminderTime = result['reminderTime'];

      setState(() {
        this.selectedTime = selectedTime; // 선택된 시간 업데이트
        isNotificationOn = newTodo.isNotification;
        taskMemo = newTodo.description;// 알림 여부 업데이트
        this.reminderTime = reminderTime; // 알림 시간 업데이트
      });

    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: Container(
          alignment: Alignment.center,
          child: Text(
            '할 일 생성 및 수정',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: 9.0),
          child: GestureDetector(
            onTap: _goBack,
            child: Container(
              width: 50,
              height: 50,
              child: Image.asset("assets/images/closebutton.png"),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: _saveTask,
              child: Container(
                width: 70,
                height: 70,
                child: Image.asset("assets/images/creationSave.png"),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                '할 일 제목을 입력해주세요',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFF95A2C),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 16.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/TextfieldName.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    taskTitle = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: '할 일 제목',
                  fillColor: Colors.transparent,
                  filled: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 25.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _navigateToTimeSetting, // 알림 시간 영역 클릭 시 시간 설정
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/timesettingBar.png'),
                    fit: BoxFit.fitWidth,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 22, horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 100.0),
                      child: Text(
                        '${selectedTime.format(context)}',
                        style: TextStyle(
                          fontSize: 35,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isNotificationOn = !isNotificationOn; // 클릭 시 상태 반전
                        });
                      },
                      child: Image.asset(
                        isNotificationOn ? 'assets/images/toggleOn.png' : 'assets/images/toggleOff.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                children: [
                  Text(
                    '카테고리를 선택해주세요',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 14.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  _buildCategoryButton(0, '운동', 'assets/images/healthbtn.png'),
                  _buildCategoryButton(1, '독서', 'assets/images/readingbtn.png'),
                  _buildCategoryButton(2, '공부', 'assets/images/studdybtn.png'),
                  _buildCategoryButton(3, '취미', 'assets/images/hobbybtn.png'),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/TextArea.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: TextField(
                maxLines: 4,
                onChanged: (value) {
                  setState(() {
                    taskMemo = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: '할 일을 적어주세요',
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.symmetric(horizontal: 27.0, vertical: 8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(int index, String label, String imagePath) {
    bool isSelected = selectedCategory == index; // 현재 버튼이 선택되었는지 확인

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = index; // 선택된 카테고리 인덱스 업데이트
        });
      },
      child: Opacity(
        opacity: isSelected ? 1.0 : 0.5, // 선택된 버튼은 불투명하게, 나머지는 반투명하게
        child: Container(
          width: 60,
          height: 60,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage(imagePath), // 각 버튼에 맞는 이미지 경로
              fit: BoxFit.cover, // 이미지 채우기
            ),
          ),
        ),
      ),
    );
  }
}