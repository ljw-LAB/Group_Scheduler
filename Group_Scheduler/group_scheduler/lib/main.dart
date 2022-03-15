// 플러터 코어파일
import 'package:flutter/material.dart';

// Pages - 자체 제작 페이지들
import 'package:group_scheduler/pages/login_page.dart';
import 'package:group_scheduler/pages/register_page.dart';
import 'package:group_scheduler/pages/home_page.dart';
import 'package:group_scheduler/services/auth_service.dart';

// 자체 제작 서비스들
import 'package:group_scheduler/services/diary_service.dart';

// 3rd Party Packages - 외부 패키지들
import 'package:provider/provider.dart'; // 프로바이더
import 'package:firebase_core/firebase_core.dart'; // 파이어베이스

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // main 함수에서 async 사용하기 위함
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DiaryService()),
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
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
