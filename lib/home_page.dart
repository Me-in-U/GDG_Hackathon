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
  //_buildRecentActivity_buildRecentActivity_buildRecentActivity_buildRecentActivity_buildRecentActivity

  //_buildHistory_buildHistory_buildHistory_buildHistory_buildHistory

  //_buildHistoryItem_buildHistoryItem

}
