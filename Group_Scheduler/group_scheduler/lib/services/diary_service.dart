import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Diary {
  String? docId; // 도큐먼트 아이디
  String? uid; // 유저 uid
  String? text; // 내용
  DateTime? createdAt; // 작성 시간

  Diary({
    required this.docId,
    required this.uid,
    required this.text,
    required this.createdAt,
  });

  Diary.fbSerializer(Map<String, dynamic> json, String documentId) {
    docId = documentId;
    uid = json['uid'];
    text = json['text'];
    createdAt = DateTime.tryParse(json['createdAt']);
  }

  /// Diary -> Map 변경
  Map<String, dynamic> toJson() {
    return {
      "text": text,
      // DateTime은 문자열로 변경해야 jsonString으로 변환 가능.
      "createdAt": createdAt?.toIso8601String(),
    };
  }
}

class DiaryService extends ChangeNotifier {
  // 파이어베이스 bucket 컬렉션을 선택
  final bucketCollection = FirebaseFirestore.instance.collection('bucket');

  /// diaryList 빈 목록 생성
  List<Diary> diaryList = [];

  // 파이어베이스에 있는 전체 도큐먼트 호출 및 diaryList에 추가
  DiaryService() {
    bucketCollection.get().then((value) {
      value.docs.forEach((element) {
        Diary diary = Diary.fbSerializer(element.data(), element.id);
        diaryList.add(diary);
      });
      notifyListeners();
    });
  }

  /// 특정 날짜의 diary 조회
  List<Diary> getByDate(DateTime date) {
    return diaryList
        .where((diary) => isSameDay(date, diary.createdAt))
        .toList();
  }

  /// Diary 수정
  void update(Diary diary, String newContent) async {
    // docId로 데이터 조회 및 업데이트
    print(diary.docId);
    await bucketCollection.doc(diary.docId).update({'text': newContent});

    diary.text = newContent;
    notifyListeners();
  }

  /// Diary 삭제
  void delete(Diary diary) async {
    // docId로 데이터 조회 및 삭제
    await bucketCollection.doc(diary.docId).delete();

    // 다이어리 리스트에서도 삭제
    diaryList.remove(diary);
    notifyListeners();
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

    Diary now_added = Diary(
        uid: uid,
        text: text,
        createdAt: now_time,
        docId: bucketCollection.doc().id);
    diaryList.add(now_added);
  }
}
