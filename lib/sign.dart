import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'auth.dart';

class SignWidget extends StatelessWidget { // 회원가입 화면
  final String uid;

  SignWidget({required this.uid});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();



  void signUp(BuildContext context) {
    final name = nameController.text;
    final email = emailController.text;
    final password = pwController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      // 입력값이 비어있는 경우 알림 표시
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('입력 오류'),
          content: Text('모든 정보를 입력해야 합니다.', style: TextStyle(fontSize: 18)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    // 입력값이 모두 채워진 경우
    print('Name: $name, Email: $email, Password: $password');


    // 예: 서버 통신 후 성공 시 다음 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginWidget()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(125.0),
        child: Padding(
          padding: EdgeInsets.only(left: 30.0, top: 40.0),
          child: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Image.asset("assets/images/backbutton.png"),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  '회원가입',
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 40),
                AuthTextField(
                  controller: nameController,
                  obscureText: false,
                  labelText: 'name',
                  imagePath: 'assets/images/user.png',
                ),
                SizedBox(height: 20),
                AuthTextField(
                  controller: emailController,
                  obscureText: false,
                  labelText: 'Email',
                  imagePath: 'assets/images/mail.png',
                ),
                SizedBox(height: 20),
                AuthTextField(
                  controller: pwController,
                  obscureText: true,
                  labelText: 'PW',
                  imagePath: 'assets/images/lock.png',
                ),
                SizedBox(height: 50),

                ElevatedButton(
                  onPressed: () => Auth().signIn(emailController.text, nameController.text, pwController.text),
                  child: Image.asset("assets/images/joinsignbutton.png"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '이미 계정이 있으시나요? ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // 로그인 창으로 이동
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginWidget()));
                        },
                        child: Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrangeAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
