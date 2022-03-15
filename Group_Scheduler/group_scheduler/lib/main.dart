import 'package:flutter/material.dart';
import 'components/';

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
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Tip : 기기 높이의 %로 줘야 각 기기별로 적절한 위치에 배치할 수 있어요.
                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                    /// 예약내역
                    Text(
                      "Group Scheduler",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                      ),
                    ),
                    SizedBox(height: 20),

                    /// 이메일
                    TextField(
                      //controller: emailController,
                      decoration: InputDecoration(hintText: "이메일"),
                    ),
                    SizedBox(height: 32),

                    /// 비밀번호
                    TextField(
                      //controller: passwordController,
                      obscureText: false, // 비밀번호 안보이게
                      decoration: InputDecoration(hintText: "비밀번호"),
                    ),
                    SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity, // <-- match_parent
                      child: ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ))),

                        /// 로그인 버튼
                        child: Text(
                          "로그인",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        onPressed: () {
                          // 로그인 성공시 HomePage로 이동
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(builder: (_) => HomePage()),
                          // );
                        },
                      ),
                    ),

                    SizedBox(
                      width: double.infinity, // <-- match_parent
                      child: ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ))),

                        /// 회원가입 버튼
                        child: Text(
                          "회원가입",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        onPressed: () {
                          // 회원가입
                          print("sign up");
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
