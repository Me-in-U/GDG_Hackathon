import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';

// 랜덤 이름 생성 함수
String generateRandomName() {
  List<String> names = [
    'John Doe', 'Jane Smith', 'Alex Johnson', 'Emily Davis', 'Michael Brown',
    'Sarah Miller', 'David Wilson', 'Sophia Moore', 'Daniel Taylor', 'Olivia Anderson'
  ];
  Random random = Random();
  return names[random.nextInt(names.length)];
}

class RankingPage extends StatelessWidget {
  const RankingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3A8D99),
        title: Text(
          'Ranking',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
      ),
      backgroundColor: Colors.transparent, // 배경을 투명으로 설정
      body: Stack(
        children: [
          // 상단 색상 설정 (위쪽)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,  // 상단 영역 높이 설정
              color: Color(0xFF3A8D99), // 위쪽 색상
            ),
          ),
          // 하단 색상 설정 (아래쪽)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.19,  // 하단 시작 위치
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white, // 아래쪽 색상 (흰색)
            ),
          ),
          // Content 영역
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Your global rank
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_circle, size: 40, color: Color(0xFF3A8D99)), // 아이콘
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your global rank', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          Text('Emily Davis', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text('5,067 steps', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Today's champions
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),  // 화면 높이에 비례한 마진
                  child: Text(
                    "Today's Champions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                SizedBox(height: 20),
                // Champion List
                _buildChampionRank(1, '100,473', Icons.account_circle),
                _buildChampionRank(2, '98,548', Icons.account_circle),
                _buildChampionRank(3, '97,876', Icons.account_circle),
                _buildChampionRank(4, '97,293', Icons.account_circle),
                _buildChampionRank(5, '97,293', Icons.account_circle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChampionRank(int rank, String steps, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      margin: const EdgeInsets.only(bottom: 10.0, left: 16.0, right: 16.0), // 마진 늘리기
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Row(
        children: [
          // 순위 표시 (1위는 왕관 아이콘, 그 외는 숫자 표시)
          CircleAvatar(
            backgroundColor: Colors.green,
            child: rank == 1
                ? Transform.translate(
              offset: Offset(-2, 0), // 왕관을 왼쪽으로 5만큼 이동
              child: Icon(
                FontAwesomeIcons.crown, // 왕관 아이콘
                size: 25, // 크기
                color: Colors.yellow, // 색상
              ),
            )
                : Text(
              '$rank',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          SizedBox(width: 16),
          Icon(icon, size: 40, color: Colors.blue),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                generateRandomName(), // 랜덤 이름 생성
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '$steps steps', // 스텝 수
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
