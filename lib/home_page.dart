import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'badge_page.dart';
import 'package:gdg_hackathon/get_image.dart';

class HomePage extends StatelessWidget {
  final String username;

  const HomePage({required this.username});

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5FF),
      appBar: AppBar(
        title: Text(
          '런투게더',
          style: TextStyle(
            fontFamily: 'YourFontName', // Use the desired font name
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        automaticallyImplyLeading: false, // Remove back button


      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            _buildRecentActivity(),
            _buildHistory(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to BadgePage on tap
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BadgePage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage('https://example.com/user_image.jpg'),
              radius: 30,
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Your profile description',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.fromLTRB(16,4,16, 4), // 상하좌우에 16의 여백 추가
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 거리',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '50 км',
                style: TextStyle(fontSize: 16, color: Colors.blueAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '달린거리 35 км',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '남은거리 15 км',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: 35 / 50, // 현재 거리 / 목표 거리
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(username) // 사용자 이름을 사용
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('오류 발생: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!['history'] == null) {
          return Text('기록이 없습니다.');
        } else {
          List<dynamic> historyList = snapshot.data!['history']; // 배열 가져오기

          return Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '기록',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: historyList.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      var item = historyList[index];
                      return _buildHistoryItem(
                        item['distance'] ?? '',
                        item['routeName'] ?? '',
                        item['date'] ?? '',
                        item['calories'] ?? '',
                        context,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }


  Widget _buildHistoryItem(String distance, String routeName, String calories, String date, BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              // Firestore에서 Base64로 저장된 이미지를 가져오는 함수
              future: GetImage.getBase64StringFromFirestore(routeName),  // 이 함수에서 Base64 문자열을 가져온다
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(child: CircularProgressIndicator()),  // 로딩 중에는 로딩 아이콘 표시
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(Icons.error, color: Colors.red),  // 오류 표시
                  );
                } else if (snapshot.hasData) {
                  // Firestore에서 가져온 Base64 문자열을 Uint8List로 변환
                  Uint8List imageBytes = base64Decode(snapshot.data!);

                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: MemoryImage(imageBytes),  // 메모리에서 이미지를 로드
                        fit: BoxFit.contain,  // 이미지가 컨테이너를 덮도록 설정
                      ),
                    ),
                  );
                } else {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(Icons.image, color: Colors.blue),  // 기본 아이콘 표시
                  );
                }
              },
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    distance,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    routeName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        date,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        calories,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
