import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RankingScreen extends StatefulWidget {
  final String username;

  const RankingScreen({Key? key, required this.username}) : super(key: key);

  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Future<Map<String, dynamic>> fetchRanking() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('totalDistance', descending: true)
        .get();

    List<Map<String, dynamic>> allUsers = [];
    int userRank = -1;

    for (int i = 0; i < snapshot.docs.length; i++) {
      final userDoc = snapshot.docs[i];
      final user = {
        'name': userDoc.id,
        'totalDistance': userDoc['totalDistance'] as num,
      };
      allUsers.add(user);

      if (userDoc.id == widget.username) {
        userRank = i + 1; // 현재 유저의 등수 계산
      }
    }

    return {
      'userRank': userRank,
      'userDistance': allUsers.firstWhere((user) => user['name'] == widget.username)['totalDistance'],
      'topUsers': allUsers.take(10).toList(), // 상위 10명
    };
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xaF3A8D99),
        title: const Text(
          '거리 랭킹',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false, // 뒤로 가기 버튼 제거
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchRanking(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load rankings.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data!;
          final int userRank = data['userRank'];
          final double userDistance = (data['userDistance'] as num).toDouble();
          final List<Map<String, dynamic>> topUsers = data['topUsers'];

          _controller.reset();
          _controller.forward(); // 슬라이드 애니메이션 시작

          return Stack(
            children: [
              // 상단 배경 색상
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  color: const Color(0xaF3A8D99),
                ),
              ),
              // 하단 배경 색상
              Positioned(
                top: MediaQuery.of(context).size.height * 0.18,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.white,
                ),
              ),
              // 본문 내용
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 나의 등수 표시
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
                          CircleAvatar(
                            backgroundColor: const Color(0xFF3A8D99),
                            radius: 25,
                            child: Text(
                              '$userRank',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.username,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${userDistance.toStringAsFixed(2)} km',
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Top 10",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 30),
                    // 상위 10명 리스트
                    Expanded(
                      child: ListView.builder(
                        itemCount: topUsers.length,
                        itemBuilder: (context, index) {
                          final user = topUsers[index];
                          final rank = index + 1;
                          final name = user['name'];
                          final distanceKm = (user['totalDistance'] as num).toDouble().toStringAsFixed(2);

                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.5, 0), // 오른쪽에서 시작
                              end: Offset.zero, // 제자리로 이동
                            ).animate(CurvedAnimation(
                              parent: _controller,
                              curve: Interval(
                                index * 0.1, // 각 항목의 시작 타이밍을 다르게 설정
                                1.0,
                                curve: Curves.easeOut,
                              ),
                            )),
                            child: _buildRankTile(rank, name, distanceKm),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRankTile(int rank, String name, String distanceKm) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      margin: const EdgeInsets.only(left:5,right:5,bottom: 10.0),
      decoration: BoxDecoration(
        gradient: rank == 1
            ? const LinearGradient(
          colors: [Color(0xFFFFCA28), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : rank == 2
            ? const LinearGradient(
          colors: [Color(0xFFBDBDBD), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : rank == 3
            ? const LinearGradient(
          colors: [Color(0xFF8D6E63), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: rank > 3 ? Colors.white : null,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Row(
        children: [
          // Rank 표시
          CircleAvatar(
            backgroundColor: rank == 1
                ? Colors.amber
                : rank == 2
                ? Colors.grey
                : rank == 3
                ? Colors.brown
                : Colors.blue,
            radius: 20,
            child: rank <= 3
                ? Icon(Icons.star, color: Colors.white)
                : Text(
              '$rank',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          // 유저 이름과 거리
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$distanceKm km',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
