import 'package:flutter/material.dart';

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
            fontFamily: 'YourFontName', // 사용하려는 폰트 이름으로 변경
            fontWeight: FontWeight.bold, // 굵은 글씨 설정
            fontSize: 20, // 폰트 크기 설정
          ),
        ),
        automaticallyImplyLeading: false, // 뒤로 가기 버튼 제거
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildRecentActivity(),
            _buildHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0), // 상하좌우에 16의 여백 추가
      decoration: BoxDecoration(
        color: Colors.white, // 배경색을 하얀색으로 설정
        borderRadius: BorderRadius.circular(12.0), // 둥근 모서리 설정
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
            radius: 30, // 프로필 사진 크기 조정
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ronnie',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Your profile description', // 예시로 간단한 설명 추가
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                'Your profile description', // 예시로 간단한 설명 추가
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
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



  Widget _buildHistory() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(16.0), // 상하좌우에 16의 여백 추가
        decoration: BoxDecoration(
          color: Colors.white, // 연한 배경 색상
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'History1',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildHistoryItem('26 мая', '10,12 км', '701 ккал', '11,2 км/ч'),
                Divider(),
                _buildHistoryItem('27 мая', '9,89 км', '669 ккал', '10,8 км/ч'),
                Divider(),
                _buildHistoryItem('28 мая', '9,12 км', '608 ккал', '10 км/ч'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String date, String distance, String calories, String speed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300, // 임시 배경 색상 (지도의 이미지 대신 사용)
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(Icons.map, color: Colors.blue), // 임시 아이콘, 지도 이미지 대신
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  distance,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      calories,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      speed,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
