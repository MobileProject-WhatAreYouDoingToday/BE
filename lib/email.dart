// 시간 많이 남으면 ㄱㄱ
import 'package:flutter_email_sender/flutter_email_sender.dart';

class Mail {
  late Email email;

  Mail(String mail, int code) {
    email = Email(
      body: '''
                <!doctype html>
        <html lang="ko">
        <head>
          <meta charset="utf-8">
          <title>ChangePW</title>
          <script>
            function generateRandomCode() {
              var code = Math.floor(1000 + Math.random() * 9000);
              document.getElementById('authCode').innerText = code;
            }
            window.onload = generateRandomCode;
          </script>
        </head>
        <body style="background-color: #F97E37;">
          <div style="text-align: center; margin:auto; border-radius: 2rem; margin-top: 40px; width: 560px; background-color: white;">
            <div style="margin-top: 100px;">    
                <img style="margin-top: 30px;" src="https://github.com/MobileProject-WhatAreYouDoingToday/BE/blob/main/assets/images/logo.png?raw=true" alt="WhatAreYouDoingToday" width="200" height="200" data-bit="iit">
            </div>
            <h1>오늘 뭐해?</h1>
            <h2>오늘 뭐해? 계정 암호 변경</h2>
            <div style="margin-top: 40px;">
              <div style="border-radius: 2rem; background-color: #FFBD12; padding: 40px; text-align: center;">
                <p style="margin:0; text-align:center; font-size:18px; color:#758592">인증 코드</p>
                <p id="authCode" style="margin:0; margin-top:24px; text-align:center; font-size:36px; letter-spacing:0.1em; color:#000"></p>
              </div>
            </div>
          </div>
        </body>
        </html>
      ''',
      subject: '오늘 뭐해? 계정 암호 변경',
      recipients: [mail],
      isHTML: true,
    );
  }

  Future<void> send() async {
    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      print("Failed to send email: $error");
    }
  }
}
