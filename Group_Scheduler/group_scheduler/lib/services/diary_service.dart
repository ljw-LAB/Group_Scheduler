import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Diary {
  String? uid;
  String? text; // 내용
  DateTime? createdAt; // 작성 시간

  Diary({
    required this.uid,
    required this.text,
    required this.createdAt,
  });

  Diary.fbSerializer(Map<String, dynamic> json) {
    uid = json['uid'];
    text = json['text'];
    createdAt = DateTime.tryParse(json['createdAt']);
  }

  /// Diary -> Map 변경
  Map<String, dynamic> toJson() {
    return {
      "text": text,
      // DateTime은 문자열로 변경해야 jsonString으로 변환 가능합니다.
      "createdAt": createdAt?.toIso8601String(),
    };
  }
}

class DiaryService extends ChangeNotifier {
  // 파이어베이스기반 코드
  final bucketCollection = FirebaseFirestore.instance.collection('bucket');

  /// Diary 목록
  List<Diary> diaryList = [];

  DiaryService() {
    bucketCollection.get().then((value) {
      value.docs.forEach((element) {
        Diary diary = Diary.fbSerializer(element.data());
        diaryList.add(diary);
      });
      notifyListeners();
    });
  }

  /// 특정 날짜의 diary 조회
  List<Diary> getByDate(DateTime date) {
    // 파이어베이스 가장 위에있는 데이터 불러오는 코드

    // return bucketCollection.where('uid', isEqualTo: uid).get();

    // inspect(diaryList);
    return diaryList
        .where((diary) => isSameDay(date, diary.createdAt))
        .toList();
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
    print(createdAt);
    var now = DateTime.now();
    var now_time = DateTime(
      createdAt.year,
      createdAt.month,
      createdAt.day,
      now.hour,
      now.minute,
      now.second,
    );

    // bucket 만들기
    await bucketCollection.add({
      'uid': uid, // 유저 식별자
      'text': text, // 일기내용
      'createdAt': now_time.toIso8601String(), // 일기내용
    });

    Diary now_added = Diary(uid: uid, text: text, createdAt: now_time);
    diaryList.add(now_added);
  }

  void fbUpdate(String docId, bool isDone) async {
    // bucket isDone 업데이트
  }

  void fbDelete(String docId) async {
    // bucket 삭제
  }
}
