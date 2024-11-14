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
            backgroundColor: Colors.grey, // Placeholder profile image
            radius: 15,
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(  // Make the body scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Center( // Center the "Let's Run" text
                child: Text(
                  "Let's Run",
                  style: TextStyle(
                      fontSize: 14, // Reduced font size for subtlety
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600] // Made the color a lighter shade of black for less prominence
                  ),
                ),
              ),
              SizedBox(height: 10), // Space between "Let's Run" and "Map List"
              Center( // Center the "Map List" text
                child: Text(
                  'Map List',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildRecommendationCard('Fitness Training', 'Seoul -> Busan', 'Start Now', context),
              SizedBox(height: 16),
              _buildRecommendationCard('Healthy Cooking', 'Incheon -> Jeju', 'Start Now', context),
              SizedBox(height: 16),
              _buildRecommendationCard('Yoga for Beginners', 'Daegu -> Gwangju', 'Start Now', context),
              SizedBox(height: 16),
              _buildRecommendationCard('Running Challenge', 'Daejeon -> Ulsan', 'Start Now', context),
              SizedBox(height: 16),
              _buildRecommendationCard('Healthy Eating Tips', 'Busan -> Seoul', 'Start Now', context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(String title, String description, String buttonText, BuildContext context) {
    return Container(
      height: 250,  // Set a fixed height for the card
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background design pattern (use an image or a custom icon)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100, // Placeholder background color
                  image: DecorationImage(
                    image: AssetImage('assets/images/background_pattern.png'),
                    fit: BoxFit.cover,
                    opacity: 0.2,  // Make the pattern light
                  ),
                ),
              ),
              // Transparent film (overlay with transparency)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2), // Dark overlay for the entire card
                ),
              ),
              // Description and button overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        description,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Starting $title')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Button background color
                          foregroundColor: Colors.black, // Button text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: Size(double.infinity, 48), // Full width button
                        ),
                        child: Text(
                          buttonText,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
