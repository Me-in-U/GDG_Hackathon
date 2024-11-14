import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String username;

  const HomePage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Tracker'),
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
            _buildWeeklyGoal(),
            _buildRecentActivity(),
            _buildHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage('https://example.com/user_image.jpg'),
      ),
      title: Text('Ronnie', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildWeeklyGoal() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text('총거리 50 км', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('달린 거리 35 км', style: TextStyle(fontSize: 16)),
              Text('남은 거리 15 км', style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return ListTile(
      leading: Icon(Icons.run_circle, size: 50),
      title: Text('총 달린 거리'),
      subtitle: Text('01:09:44'),
      trailing: Text('10,9 км'),
    );
  }

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildHistoryItem('26 мая', '10,12 км', '701 ккал', '11,2 км/ч'),
            _buildHistoryItem('27 мая', '9,89 км', '669 ккал', '10,8 км/ч'),
            _buildHistoryItem('28 мая', '9,12 км', '608 ккал', '10 км/ч'),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryItem(String date, String distance, String calories, String pace) {
    return ListTile(
      leading: Icon(Icons.map, size: 50),
      title: Text('$date $distance', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('$calories $pace'),
    );
  }
}
