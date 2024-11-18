import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'email.dart';
import 'store.dart';

final Auth auth = Auth();

class Auth { // 계정 정보를 담는 클래스
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Store store = Store();
  UserCredential? userCredential;


  Future<void> logIn(String email, String password) async { // 로그인을 할 경우 userCredintial로 로그인한 계정 정보를 저장함.
    try {
      userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("로그인 성공함: ${userCredential?.user?.email}");
    } catch (e) {
      print("로그인 실패함: $e");
    }
  }

  Future<void> signIn(String email, String password, String name) async { // 회원가입을 하고 파이어스토어 문서를 생성함
    try {
      userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("회원가입 성공함: ${email}");
      store.setUser(userCredential!.user!.uid, name, email); // 이 부분이 그거임
      userCredential = null;
    } catch (e) {
      print("회원가입 실패함: $e");
    }
  }

  // Future<void> sendPwRefactorEmail(String email, int code) async { 시간 많이 남으면 ㄱㄱ
  //   int code = math.Random().nextInt(100);
  //   Mail mail = Mail(email, code);
  //   try{
  //     mail.send();
  //     // if(this.code==code){
  //     //  await auth.updatePassword(newPassword);
  //     // }
  //   } catch(e){
  //     print("회원가입 실패함: $e");
  //   }
  // }
}


class LoginWidget extends StatelessWidget { // 로그인 화면
  createUserWithEmailAndPassword() {
    // TODO: implement createUserWithEmailAndPassword
    throw UnimplementedError();
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "login",
      home: Scaffold(
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
                icon: Image.asset("assets/images/closebutton.png"),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/images/logo.png", width: 200),
                  Text(
                    '로그인',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 40),
                  AuthTextField(
                    controller: emailController,
                    obscureText: false,
                    labelText: 'E-mail',
                    imagePath: 'assets/images/user.png',
                  ),
                  SizedBox(height: 20),
                  AuthTextField(
                    controller: pwController,
                    obscureText: true,
                    labelText: 'PW',
                    imagePath: 'assets/images/lock.png',
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      auth.logIn(emailController.text, pwController.text);
                      // 로그인 메소드 넣어야 함
                      if(auth.userCredential!=null){
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => MainWidget(user_uid:auth.user.uid),));
                      }
                      print('버튼이 클릭되었습니다!');
                    },
                    child: Image.asset("assets/images/loginIcon.png"),
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
                          '처음 이용하시나요?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // 회원가입 창으로 이동해야 함
                          },
                          child: Text(
                            ' 회원가입',
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
                  SizedBox(height: 5),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ID / PW 잊으셨나요?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // ID/PW 찾기 창으로 이동해야 함
                          },
                          child: Text(
                            ' ID / PW 찾기',
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
      ),
    );
  }
}

class SignInWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }

}

class AuthTextField extends StatelessWidget { // 로그인 화면의 textfield 회원가입 화면이나 ID/PW 찾기에서도 사용해도 될 듯
  final bool obscureText;
  final String labelText;
  final String imagePath;
  final TextEditingController controller;

  AuthTextField({required this.controller, required this.obscureText, required this.labelText, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 329,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Image.asset(imagePath),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(width: 2.0),
          ),
        ),
      ),
    );
  }
}
