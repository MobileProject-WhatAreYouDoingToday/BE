import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'MainWidget.dart';
import 'store.dart';

final Auth authe = Auth();

class Auth { // 계정 정보를 담는 클래스
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Store store = Store();
  UserCredential? userCredential;

  Future<bool> logIn(String email, String password) async { // 로그인을 할 경우 userCredintial로 로그인한 계정 정보를 저장함.
    bool b;
    try {
      userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      b = true;
      print("로그인 성공함: ${userCredential?.user?.email}");
    } catch (e) {
      print("로그인 실패함: $e");
      b = false;
    }

    return b;
  }

  Future<void> signIn(String email, String name, String pw) async { // 회원가입을 하고 파이어스토어 문서를 생성함
    try {
      userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: pw,
      );

      store.setUser(email, userCredential!.user!.uid, name, pw);
      print("회원가입 성공함: ${email}");
      userCredential = null;
    } catch (e) {
      print("회원가입 실패함: $e");
    }
  }

  Future<void> sendPwChangeEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('비밀번호 재설정 이메일이 전송되었습니다.');
    } catch  (e){
      print('비밀번호 재설정 이메일이 전송되었습니다.');
    }
  }

  Future<void> changePw(String newPw, String checkNewPw) async {
    try {
      if(newPw == checkNewPw){
        await auth.currentUser?.updatePassword(newPw);
        print('비밀번호가 재설정 되었습니다.');
      }
    } catch  (e){
      print('비밀번호 재설정 이메일이 전송되었습니다.');
    }
  }
}

class LoginWidget extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null); // 에러 메시지 상태 관리

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(125.0),
        child: Padding(
          padding: EdgeInsets.only(left: 30.0, top: 40.0),
          child: AppBar(
            scrolledUnderElevation: 0,
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
                SizedBox(height: 30),
                // 에러 메시지를 표시하는 공간 (아이디 입력창 위로 이동)
                ValueListenableBuilder<String?>(
                  valueListenable: errorMessage,
                  builder: (context, value, child) {
                    return SizedBox(
                      height: 30, // 항상 일정한 공간 차지
                      child: Center(
                        child: value != null
                            ? Text(
                          value,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        )
                            : SizedBox.shrink(), // 메시지가 없으면 빈 공간
                      ),
                    );
                  },
                ),
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (emailController.text.isEmpty || pwController.text.isEmpty) {
                      // 입력값이 비어있는 경우 에러 메시지 설정
                      errorMessage.value = "모든 정보를 입력해야 합니다.";
                    } else {
                      // 로그인 시도
                      bool loginSuccess = await authe.logIn(
                        emailController.text,
                        pwController.text,
                      );

                      if (loginSuccess) {
                        // 로그인 성공: 메인 화면으로 이동
                        errorMessage.value = null; // 에러 메시지 초기화
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainWidget(auth: authe)),
                        );
                      } else {
                        // 로그인 실패: 에러 메시지 표시
                        errorMessage.value = "정보를 다시 입력해주세요";
                      }
                    }
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
                          // 회원가입 창으로 이동
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SignWidget()));
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
                          authe.userCredential==null;
                          Navigator.push(context, MaterialPageRoute(builder: (context) => WillChangePwWidget()));
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
    );
  }
}


class ChangePwWidget extends StatelessWidget { // 로그인 화면
  final TextEditingController newPwController = TextEditingController();
  final TextEditingController checkNewPwController = TextEditingController();
  final Auth auth;
  final UserData user;

  ChangePwWidget({required this.auth, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(125.0),
        child: Padding(
          padding: EdgeInsets.only(left: 30.0, top: 40.0),
          child: AppBar(
            scrolledUnderElevation: 0,
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
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.only(left: 5.0,),
                    child: Column(
                      children: [
                        Text(
                          'PW 변경',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                ),
                Padding(padding: EdgeInsets.only(left: 5.0, top: 20.0,),
                    child: Column(
                      children: [
                        Text(
                          'PW를 재설정해주세요',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w100, color: Color(0xFF474A57)),
                        ),
                      ],
                    )
                ),
                SizedBox(height: 40),
                AuthTextField(
                  controller: newPwController,
                  obscureText: false,
                  labelText: 'New PW',
                  imagePath: 'assets/images/user.png',
                ),
                SizedBox(height: 20),
                AuthTextField(
                  controller: checkNewPwController,
                  obscureText: true,
                  labelText: 'Check New PW',
                  imagePath: 'assets/images/lock.png',
                ),
                SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () {
                    // auth.sendPwChangeEmail(newPwController.text);
                    auth.changePw(newPwController.text, checkNewPwController.text); // Auth 상에서의 비밀번호 변경 메소드
                    Store().setUser(auth.userCredential?.user!.email, user.uid, user.name, newPwController.text); // firestore 상에서의 비밀번호 변경 메소드
                    auth.userCredential == null;
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginWidget()));
                    print('버튼이 클릭되었습니다!');
                  },
                  child: Image.asset("assets/images/changepwbutton.png"),
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
                        '이미 계정이 있으신가요??',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // 회원가입 창으로 이동해야 함
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginWidget()));
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WillChangePwWidget extends StatelessWidget { // 로그인 화면

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(125.0),
        child: Padding(
          padding: EdgeInsets.only(left: 30.0, top: 40.0),
          child: AppBar(
            scrolledUnderElevation: 0,
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
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.only(left: 5.0,),
                    child: Column(
                      children: [
                        Text(
                          'PW 변경',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                ),
                Padding(padding: EdgeInsets.only(left: 5.0, top: 20.0,),
                    child: Column(
                      children: [
                        Text(
                          '이름 및 계정 이메일을 입력해주세요',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w100, color: Color(0xFF474A57)),
                        ),
                      ],
                    )
                ),
                SizedBox(height: 40),
                AuthTextField(
                  controller: nameController,
                  obscureText: false,
                  labelText: '이름',
                  imagePath: 'assets/images/user.png',
                ),
                SizedBox(height: 20),
                AuthTextField(
                  controller: emailController,
                  obscureText: false,
                  labelText: 'E-mail',
                  imagePath: 'assets/images/mail.png',
                ),
                SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // 유저 크레덴셜 초기화
                      authe.userCredential = null;

                      // 유저 크레덴셜이 null일 때만 처리
                      if (authe.userCredential == null) {
                        UserData? c_user = await authe.store.getUser(emailController.text);

                        if (c_user != null&&c_user.name == nameController.text) {
                          print(c_user.name);
                          authe.userCredential = await authe.auth.signInWithEmailAndPassword(
                              email: emailController.text,
                              password: c_user.pw
                          );
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePwWidget(auth: authe, user: c_user,)));
                        }
                      } else {
                        print('유저 정보를 불러올 수 없습니다.');
                        return;
                      }
                    } catch (e) {
                      print('오류 발생: $e');
                      authe.userCredential = null; // 오류 발생 시 null로 재설정
                    }
                  },
                  child: Image.asset("assets/images/confirmbutton.png"),
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
                        '이미 계정이 있으신가요??',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // 회원가입 창으로 이동해야 함
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginWidget()));
                        },
                        child: Text(
                          ' 로그인',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignWidget extends StatelessWidget { // 회원가입 화면
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
            scrolledUnderElevation: 0,
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
                  onPressed: () async {
                    signUp(context);
                    Auth().signIn(emailController.text, nameController.text, pwController.text);
                    print(pwController.text);
                  },
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