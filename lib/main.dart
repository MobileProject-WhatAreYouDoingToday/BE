import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whatareyoudoingtoday/auth.dart';
import 'sign.dart';
import 'creation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: new LoginWidget(),
  ));
}

