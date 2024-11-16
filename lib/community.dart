import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // For location services
import 'detail_page.dart';

class Community extends StatefulWidget {
  final Function(String routeName) onRouteSelected;

  const Community({Key? key, required this.onRouteSelected}) : super(key: key);

  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  Position? _userPosition;
  bool _isLoadingPosition = true;  // 위치 로딩 상태 관리 변수 추가

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userPosition = position;
        _isLoadingPosition = false;  // 위치 정보 로드 완료
      });
    } catch (e) {
      setState(() {
        _isLoadingPosition = false;  // 위치 정보 로드 실패 처리
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치를 가져오는데 실패했습니다.')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '경로 커뮤니티',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('routes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isLoadingPosition) {
            return const Center(child: CircularProgressIndicator());  // 위치 로딩 중 로딩 화면 표시
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No routes found.'));
          }

          final routes = snapshot.data!.docs;

          if (_userPosition != null) {
            // Sort routes by proximity to the user
            routes.sort((a, b) {
              final aPoints = a['points'] as List<dynamic>? ?? [];
              final bPoints = b['points'] as List<dynamic>? ?? [];

              if (aPoints.isEmpty || bPoints.isEmpty) return 0;

              final aFirst = aPoints.first;
              final bFirst = bPoints.first;

              final aDistance = Geolocator.distanceBetween(
                _userPosition!.latitude,
                _userPosition!.longitude,
                aFirst['lat'],
                aFirst['lng'],
              );

              final bDistance = Geolocator.distanceBetween(
                _userPosition!.latitude,
                _userPosition!.longitude,
                bFirst['lat'],
                bFirst['lng'],
              );

              return aDistance.compareTo(bDistance);
            });
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              final routeName = route.id;
              final imageBase64 = route['image'] as String?;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildRecommendationCard(
                  routeName,
                  'Start Now',
                  context,
                  imageBase64 != null ? Image.memory(base64Decode(imageBase64)) : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecommendationCard(
      String title, String buttonText, BuildContext context, Widget? imageWidget) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              top: -20,
              child: imageWidget ?? Container(color: Colors.grey[300]),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.0),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedRoute = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              title: title,
                              description: "Description of $title",
                            ),
                          ),
                        );

                        if (selectedRoute != null) {
                          widget.onRouteSelected(selectedRoute);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
