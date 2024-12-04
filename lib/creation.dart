import 'package:flutter/material.dart';
import 'auth.dart';
import 'timesetting.dart'; // 시간 설정 화면을 위한 파일 임포트
import 'package:cloud_firestore/cloud_firestore.dart';
import 'store.dart'; // Todo 클래스를 포함한 task.dart
import 'notification_service.dart';


class CreationPage extends StatefulWidget {
  final String email;
  final Todo? todo;
  const CreationPage({super.key, required this.email, required this.todo});

  @override
  _CreationPageState createState() => _CreationPageState(email, todo);
}

class _CreationPageState extends State<CreationPage> {
  final String email;
  final Todo? todo;

  String taskTitle = '';
  String taskMemo = '';
  bool isNotificationOn = false;
  DateTime selectedTime = DateTime.now();
  String? selectedCategory; // nullable 변수
  int? reminderTime;
  TextEditingController nameController = TextEditingController();
  TextEditingController memoController = TextEditingController();


  _CreationPageState(this.email, this.todo); // 알림 시간 변수 추가

  @override
  @override
  void initState() {
    super.initState();
    if (todo != null) {
      taskTitle = todo!.name;
      nameController.text = todo!.name;
      taskMemo = todo!.description;
      memoController.text = todo!.description;
      isNotificationOn = todo!.isNotification;
      selectedCategory = todo!.category;

      // todo의 date가 null인 경우 대비
      try {
        selectedTime = todo!.date.toDate();
      } catch (e) {
        selectedTime = DateTime.now();
        print("Error initializing selectedTime from todo: $e");
      }
    } else {
      selectedTime = DateTime.now(); // 기본값 설정
    }
  }

  Future<void> _saveTask() async {
    if(todo == null){
      if (taskTitle.isNotEmpty) {
        // Todo 객체 생성
        Todo newTodo = Todo(
          name: taskTitle,
          category: selectedCategory != "기타" ? selectedCategory.toString() : "기타", // 카테고리 설정
          date: Timestamp.now(), // 현재 시간으로 설정
          isNotification: isNotificationOn, // 알림 여부 설정
          priority: 0, // 기본 우선순위
          isCompleted: false, // 기본 완료 상태
          description: taskMemo,
        );

        print(newTodo.date);
        List<Todo>? todoList = await Store().getSelectedDateTodoList(email, newTodo.date);
        int lastP=0;

        for(int i=0;i<todoList.length;i++){
          if(todoList[i].priority==lastP){
            lastP = todoList[i].priority + 1;
            print('라스트p는 {$lastP}');
          }
        }
        newTodo.priority = lastP;

        // Todo 객체를 반환
        Navigator.pop(context, {'todo': newTodo, 'selectedTime': selectedTime});
        Store().setTodo(email, newTodo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('할 일 제목을 입력해주세요.')),
        );
      }
    } else {
      todo!.date = Timestamp.fromDate(selectedTime);
      todo!.category = selectedCategory!;
      todo!.isNotification = isNotificationOn;
      todo!.name = taskTitle;
      todo!.description = taskMemo;

      await Store().setTodo(email, todo!);
      _goBack();
    }

  }

  void _goBack() {
    Navigator.pop(context);
  }

  // 알림 시간 설정 페이지로 이동
  void _navigateToTimeSetting() async {
    // TimeSetting 페이지로 이동
    selectedTime = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TimeSetting(selectedTime: selectedTime,)),
    );
    // 반환된 데이터 처리
    setState(() {

    });

  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 40.0 - 4 * 8.0) / 4; // 40.0은 패딩, 8.0은 spacing

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        scrolledUnderElevation: 0,
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
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
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
                    controller: nameController,
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
                              '${selectedTime.hour.toString().padLeft(2, '0')} : ${selectedTime.minute.toString().padLeft(2, '0')}',
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
                  padding: EdgeInsets.only(left: 7.0, right: 7.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      _buildCategoryButton(0, '운동', 'assets/images/healthbtn.png', buttonWidth),
                      _buildCategoryButton(1, '독서', 'assets/images/readingbtn.png', buttonWidth),
                      _buildCategoryButton(2, '공부', 'assets/images/studybtn.png', buttonWidth),
                      _buildCategoryButton(3, '취미', 'assets/images/hobbybtn.png', buttonWidth),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/TextArea.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: TextField(
                    controller: memoController,
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
        )
          ),
    );
  }

  Widget _buildCategoryButton(int index, String label, String imagePath, double width) {
    bool isSelected = selectedCategory == label; // 현재 버튼이 선택되었는지 확인

    return GestureDetector(
      onTap: () {
        setState(() {
          // 선택된 카테고리 인덱스가 현재 인덱스와 같으면 비활성화, 아니면 활성화
          if (isSelected) {
            selectedCategory = "기타"; // 비활성화 상태를 나타내기 위해 -1로 설정
          } else {
            selectedCategory = label; // 선택된 카테고리 인덱스 업데이트
          }
        });
      },
      child: Opacity(
        opacity: isSelected ? 1.0 : 0.5, // 선택된 버튼은 불투명하게, 나머지는 반투명하게
        child: Container(
          width: width,
          height: width,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage(imagePath), // 각 버튼에 맞는 이미지 경로
              fit: BoxFit.cover, // 이미지 채우기
            ),
          ),
        ),
        //child: Text(label),
      ),
    );
  }
}