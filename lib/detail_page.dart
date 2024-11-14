import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final String title;
  final String description;

  // Constructor with required fields
  const DetailPage({Key? key, required this.title, required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title), // Use the title passed from the previous page
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description, // Use the description passed from the previous page
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // You can add more UI elements here based on your design
          ],
        ),
      ),
    );
  }
}
