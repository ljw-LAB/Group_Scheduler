import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:group_scheduler/pages/login_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 자체제작 서비스
import 'package:group_scheduler/services/auth_service.dart';
import 'package:group_scheduler/services/diary_service.dart';

// 자체제작 컴포넌트
// import 'package:group_scheduler/components/calendar.dart';

// 3rd Party Packages - 외부 패키지들
import 'package:table_calendar/table_calendar.dart'; // 테이블 캘린더
import 'package:intl/intl.dart'; // DateTime 형식 지정 외부 패키지
import 'package:provider/provider.dart'; // 프로바이더

// 한줄일기 내용 저장 변수
late String diary_string;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 달력 보여주는 형식
  CalendarFormat calendarFormat = CalendarFormat.month;

  // 선택된 날짜
  DateTime selectedDate = DateTime.now();

  // create text controller
  TextEditingController createTextController = TextEditingController();

  // update text controller
  TextEditingController updateTextController = TextEditingController();

  // Notifications Plugin 생성
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // 알림 초기화
    init();
  }

  void init() async {
    // 알림용 ICON 설정
    // https://ichi.pro/ko/flutterlo-pusi-allim-eul-sayonghaneun-bangbeob-39302606388818 IOS, MAC OS 초기화 참조

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(onDidReceiveLocalNotification: null);
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // final InitializationSettings initializationSettings =
    //     InitializationSettings(android: initializationSettingsAndroid);

    // // 알림 초기화
    // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 알림 발생 함수!!
  Future<void> _showGroupedNotifications() async {
    // 알림 그룹 키
    const String groupKey = 'com.example.group_scheduler';
    // 알림 채널
    const String groupChannelId = 'grouped channel id';
    // 채널 이름
    const String groupChannelName = 'grouped channel name';

    // 채널 설명
    //const String groupChannelDescription = 'grouped channel description';

    // 안드로이드 알림 설정
    const AndroidNotificationDetails notificationAndroidSpecifics =
        AndroidNotificationDetails(groupChannelId, groupChannelName,
            importance: Importance.max,
            priority: Priority.high,
            groupKey: groupKey);

    // 플랫폼별 설정 - 현재 안드로이드만 적용됨
    const NotificationDetails notificationPlatformSpecifics =
        NotificationDetails(android: notificationAndroidSpecifics);

    // 알림 발생!
    await flutterLocalNotificationsPlugin.show(
        1,
        'Group_scheduler ${DateFormat('yy/MM/dd').format(selectedDate)}',
        diary_string,
        notificationPlatformSpecifics);
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser()!;
    return Consumer<DiaryService>(
      builder: (context, diaryService, child) {
        List<Diary> diaryList = diaryService.getByDate(selectedDate);
        return Scaffold(
          // 키보드가 올라올 때 화면 밀지 않도록 만들기(overflow 방지)
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // 로그아웃
                          context.read<AuthService>().signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                        child: Text(
                          '로그아웃',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),

                  /// 달력

                  TableCalendar(
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: selectedDate,
                    calendarFormat: calendarFormat,
                    onFormatChanged: (format) {
                      // 달력 형식 변경
                      setState(() {
                        calendarFormat = format;
                      });
                    },
                    eventLoader: (date) {
                      // 각 날짜에 해당하는 diaryList 보여주기
                      return diaryService.getByDate(date);
                    },
                    calendarStyle: CalendarStyle(
                      // today 색상 제거
                      todayTextStyle: TextStyle(color: Colors.black),
                      todayDecoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.rectangle,
                      ),
                    ),
                    selectedDayPredicate: (day) {
                      return isSameDay(selectedDate, day);
                    },
                    onDaySelected: (_, focusedDay) {
                      setState(() {
                        selectedDate = focusedDay;
                      });
                    },
                  ),

                  Divider(height: 1),

                  /// 선택한 날짜의 일기 목록
                  Expanded(
                    child: diaryList.isEmpty
                        ? Center(
                            child: Text(
                              "한 줄 일기를 작성해주세요.",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: diaryList.length,
                            itemBuilder: (context, index) {
                              // 역순으로 보여주기
                              int i = diaryList.length - index - 1;
                              final doc = diaryList[index];
                              String text = diaryList[index].text ?? '';
                              DateTime createdAt =
                                  diaryList[index].createdAt ?? DateTime.now();
                              return ListTile(
                                /// text
                                title: Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.black,
                                  ),
                                ),

                                /// createdAt
                                trailing: Text(
                                  DateFormat('kk:mm').format(createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),

                                /// 클릭하여 update
                                onTap: () {
                                  showUpdateDialog(diaryService, doc);
                                },

                                /// 꾹 누르면 delete
                                onLongPress: () {
                                  showDeleteDialog(diaryService, doc);
                                },
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              // item 사이에 Divider 추가
                              return Divider(height: 1);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          /// Floating Action Button
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.create),
            backgroundColor: Colors.indigo,
            onPressed: () {
              showCreateDialog(diaryService, user);
            },
          ),
        );
      },
    );
  }

  /// 작성하기
  /// 엔터를 누르거나 작성 버튼을 누르는 경우 호출
  void createDiary(DiaryService diaryService, user) {
    // 앞뒤 공백 삭제
    String newText = createTextController.text.trim();
    if (newText.isNotEmpty) {
      // diaryService.create(newText, selectedDate);
      createTextController.text = "";
      diaryService.fbCreate(newText, user.uid, selectedDate);
      diary_string = newText;
    }
  }

  /// 수정하기
  /// 엔터를 누르거나 수정 버튼을 누르는 경우 호출
  void updateDiary(DiaryService diaryService, Diary diary) {
    // 앞뒤 공백 삭제
    String updatedText = updateTextController.text.trim();
    if (updatedText.isNotEmpty) {
      print(diary.docId);
      diaryService.update(
        diary,
        updatedText,
      );
    }
  }

  /// 작성 다이얼로그 보여주기
  void showCreateDialog(DiaryService diaryService, user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("일기 작성"),
          content: TextField(
            controller: createTextController,
            autofocus: true,
            // 커서 색상
            cursorColor: Colors.indigo,
            decoration: InputDecoration(
              hintText: "한 줄 일기를 작성해주세요.",
              // 포커스 되었을 때 밑줄 색상
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.indigo),
              ),
            ),
            onSubmitted: (_) {
              // 엔터 누를 때 작성하기
              createDiary(diaryService, user);
              Navigator.pop(context);
            },
          ),
          actions: [
            /// 취소 버튼
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "취소",
                style: TextStyle(color: Colors.indigo),
              ),
            ),

            /// 작성 버튼
            TextButton(
              onPressed: () {
                print("작성");
                createDiary(diaryService, user);
                _showGroupedNotifications();
                Navigator.pop(context);
              },
              child: Text(
                "작성",
                style: TextStyle(color: Colors.indigo),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 수정 다이얼로그 보여주기
  void showUpdateDialog(DiaryService diaryService, Diary diary) {
    showDialog(
      context: context,
      builder: (context) {
        updateTextController.text = diary.text ?? '';
        return AlertDialog(
          title: Text("일기 수정"),
          content: TextField(
            autofocus: true,
            controller: updateTextController,
            // 커서 색상
            cursorColor: Colors.indigo,
            decoration: InputDecoration(
              hintText: "한 줄 일기를 작성해 주세요.",
              // 포커스 되었을 때 밑줄 색상
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.indigo),
              ),
            ),
            onSubmitted: (v) {
              // 엔터 누를 때 수정하기
              updateDiary(diaryService, diary);
              Navigator.pop(context);
            },
          ),
          actions: [
            /// 취소 버튼
            TextButton(
              child: Text(
                "취소",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.indigo,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),

            /// 수정 버튼
            TextButton(
              child: Text(
                "수정",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.indigo,
                ),
              ),
              onPressed: () {
                // 수정하기
                updateDiary(diaryService, diary);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  /// 삭제 다이얼로그 보여주기
  void showDeleteDialog(DiaryService diaryService, Diary diary) {
    showDialog(
      context: context,
      builder: (context) {
        updateTextController.text = diary.text ?? '';
        return AlertDialog(
          title: Text("일기 삭제"),
          content: Text('"${diary.text}"를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              child: Text(
                "취소",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.indigo,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),

            /// Delete
            TextButton(
              child: Text(
                "삭제",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.indigo,
                ),
              ),
              onPressed: () {
                diaryService.delete(diary);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
