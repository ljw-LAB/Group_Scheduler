import 'package:flutter/material.dart';
import 'package:group_scheduler/pages/home_page.dart';
import 'package:group_scheduler/services/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nickNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // 유저 로그인정보 확인받아서 user변수에 할당
        final user = authService.currentUser();
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
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.15),

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
                          controller: emailController,
                          decoration: InputDecoration(hintText: "이메일"),
                        ),
                        SizedBox(height: 32),

                        /// 닉네임
                        TextField(
                          controller: nickNameController,
                          obscureText: false,
                          decoration: InputDecoration(hintText: "닉네임"),
                        ),
                        SizedBox(height: 32),

                        /// 비밀번호
                        TextField(
                          controller: passwordController,
                          obscureText: true, // 비밀번호 안보이게
                          decoration: InputDecoration(hintText: "비밀번호"),
                        ),
                        SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity, // <-- match_parent
                          child: ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
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
                              print('회원가입');
                              authService.signUp(
                                email: emailController.text,
                                nickName: nickNameController.text,
                                password: passwordController.text,
                                context: context,
                                onSuccess: () {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text("회원가입 성공"),
                                  ));
                                },
                                onError: (err) {
                                  // 에러 발생
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(err),
                                  ));
                                },
                              );
                            },
                          ),
                        ),

                        SizedBox(
                          width: double.infinity, // <-- match_parent
                          child: ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ))),

                            /// 회원가입 버튼
                            child: Text(
                              "취소",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            onPressed: () {
                              // 회원가입
                              print('로그인페이지로 이동');
                              Navigator.pop(context);
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
      },
    );
  }
}
