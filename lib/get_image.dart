import 'package:cloud_firestore/cloud_firestore.dart';

class GetImage {
  static Future<String> getBase64StringFromFirestore() async {
    // Firestore에서 저장된 데이터 가져오기 (컬렉션 이름과 문서 ID를 정확히 지정)
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('routes') // 예시로 'images' 컬렉션을 사용
        .doc('test2') // 문서 ID를 지정
        .get();

    // Firestore에서 가져온 데이터에서 Base64 문자열 추출
    String base64String = snapshot['image']; // Firestore 필드 이름 (예: 'imageData')
    return base64String;
  }
}