// 플러터 코어파일
import 'package:flutter/material.dart';

// Pages - 자체 제작 페이지들
import 'package:group_scheduler/pages/login_page.dart';

// 3rd Party Packages - 외부 패키지들
import 'package:intl/intl.dart'; // DateTime 형식 지정 외부 패키지
import 'package:provider/provider.dart'; // 프로바이더
import 'package:table_calendar/table_calendar.dart'; // 테이블 캘린더

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

Color PrimaryColor = Color.fromARGB(255, 38, 103, 240);

/// 두 번째 페이지
