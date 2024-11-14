import 'dart:convert'; // Base64 디코딩을 위한 패키지
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RouteListScreen extends StatelessWidget {
  const RouteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routes List'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('routes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No routes found.'));
          }

          final routes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              final routeName = route.id; // 라우트 이름
              final imageBase64 = route['image'] as String?; // Base64 이미지

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: imageBase64 != null
                      ? Image.memory(
                    base64Decode(imageBase64),
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  )
                      : const Icon(Icons.image, size: 50), // 이미지가 없을 때 대체 아이콘
                  title: Text(routeName),
                  onTap: () {
                    // 라우트 선택 시 작업 정의
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RouteDetailScreen(route: route),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RouteDetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot route;

  const RouteDetailScreen({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    final routeName = route.id;
    final points = route['points'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(routeName),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: points.length,
        itemBuilder: (context, index) {
          final point = points[index];
          final lat = point['lat'];
          final lng = point['lng'];

          return ListTile(
            leading: const Icon(Icons.place),
            title: Text('Point ${index + 1}'),
            subtitle: Text('Lat: $lat, Lng: $lng'),
          );
        },
      ),
    );
  }
}
