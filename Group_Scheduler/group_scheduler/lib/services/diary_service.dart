import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Diary {
  String uid;
  String text; // 내용
  DateTime createdAt; // 작성 시간

  Diary({
    required this.uid,
    required this.text,
    required this.createdAt,
  });
}

class DiaryService extends ChangeNotifier {
  // 파이어베이스기반 코드
  final bucketCollection = FirebaseFirestore.instance.collection('bucket');

  /// Diary 목록
  List<Diary> diaryList = [];

  /// 특정 날짜의 diary 조회
  List<Diary> getByDate(DateTime date, String uid) {
    // 파이어베이스 가장 위에있는 데이터 불러오는 코드
    bucketCollection.get().then((value) {
      value.docs.forEach((element) {
        print(element.data());
      });
    });

    // return bucketCollection.where('uid', isEqualTo: uid).get();

    return diaryList
        .where((diary) => isSameDay(date, diary.createdAt))
        .toList();
  }

  /// Diary 작성
  void create(String text, DateTime selectedDate) {
    DateTime now = DateTime.now();

    // 선택된 날짜(selectedDate)에 현재 시간으로 추가
    DateTime createdAt = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );

    // Diary diary = Diary(
    //   uid: uid,
    //   text: text,
    //   createdAt: createdAt,
    // );
    // diaryList.add(diary);
    notifyListeners();
  }

  /// Diary 수정
  void update(DateTime createdAt, String newContent) {
    // createdAt은 중복될 일이 없기 때문에 createdAt을 고유 식별자로 사용
    // createdAt이 일치하는 diary 조회
    Diary diary = diaryList.firstWhere((diary) => diary.createdAt == createdAt);

    // text 수정
    diary.text = newContent;
    notifyListeners();
  }

  /// Diary 삭제
  void delete(DateTime createdAt) {
    // createdAt은 중복될 일이 없기 때문에 createdAt을 고유 식별자로 사용
    // createdAt이 일치하는 diary 삭제
    diaryList.removeWhere((diary) => diary.createdAt == createdAt);
    notifyListeners();
  }

  Future<QuerySnapshot> fbRead(String uid) async {
    // 내 bucketList 가져오기
    return bucketCollection.where('uid', isEqualTo: uid).get();

    throw UnimplementedError(); // return 값 미구현 에러
  }

  void fbCreate(String text, String uid, DateTime createdAt) async {
    print(text);

    // bucket 만들기
    await bucketCollection.add({
      'uid': uid, // 유저 식별자
      'text': text, // 일기내용
      'createdAt': createdAt, // 일기내용
    });
  }

  void fbUpdate(String docId, bool isDone) async {
    // bucket isDone 업데이트
  }

  void fbDelete(String docId) async {
    // bucket 삭제
  }
}
