import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Community(),
  ));
}



class Community extends StatelessWidget {
  const Community({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Light background color
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Community',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        actions: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/profile.jpg'),
            radius: 30,
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting text
            Text(
              'Hello, Nora',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Good Morning',
              style: TextStyle(fontSize: 22, color: Colors.grey),
            ),
            SizedBox(height: 20),
            // Search bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Doctor, Food & Many More...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Recommendations heading
            Text(
              'Recommendations',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Recommendation cards
            _buildRecommendationCard(
              'https://example.com/image1.jpg', // Use a valid image URL
              'Fitness Training',
              'Start Now',
              context,
            ),
            SizedBox(height: 16),
            _buildRecommendationCard(
              'https://example.com/image2.jpg', // Use a valid image URL
              'Healthy Cooking',
              'Start Now',
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
      String imageUrl,
      String title,
      String buttonText,
      BuildContext context,
      ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background image
            Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Overlay for text and button
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4), // Dark overlay for text visibility
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      // Action when button is pressed
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Starting $title')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Set background color
                      foregroundColor: Colors.black, // Set text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
