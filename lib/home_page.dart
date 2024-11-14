import 'dart:convert';
import 'dart:typed_data';

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
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
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
            value: 35 / 50,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(BuildContext context) {
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
                'History1',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildHistoryItem('26 мая', '10,12 км', '701 ккал', '11,2 км/ч', context),
                Divider(),
                _buildHistoryItem('27 мая', '9,89 км', '669 ккал', '10,8 км/ч', context),
                Divider(),
                _buildHistoryItem('28 мая', '9,12 км', '608 ккал', '10 км/ч', context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String date, String distance, String calories, String speed, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryDetailPage(date: date, distance: distance, calories: calories, speed: speed),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: GetImage.getBase64StringFromFirestore('강변 산책로'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(Icons.error, color: Colors.red),
                  );
                } else if (snapshot.hasData) {
                  Uint8List imageBytes = base64Decode(snapshot.data!);
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: MemoryImage(imageBytes),
                        fit: BoxFit.cover,
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
                    child: Icon(Icons.image, color: Colors.blue),
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
      ),
    );
  }
}

class HistoryDetailPage extends StatelessWidget {
  final String date;
  final String distance;
  final String calories;
  final String speed;

  const HistoryDetailPage({
    Key? key,
    required this.date,
    required this.distance,
    required this.calories,
    required this.speed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: $date', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Distance: $distance', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Calories: $calories', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Speed: $speed', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
