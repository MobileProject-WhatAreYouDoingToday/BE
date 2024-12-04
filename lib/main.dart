import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'networkalert.dart'; // NetworkMonitor 가져오기
import 'auth.dart'; // LoginWidget 가져오기

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NetworkMonitor(
        child: LoginWidget(), // 첫 화면으로 LoginWidget 설정
      ),
    );
  }
}
