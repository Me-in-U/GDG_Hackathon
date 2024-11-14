import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'detail_page.dart';

void main() {
  runApp(MaterialApp(
    home: Community(),
    debugShowCheckedModeBanner: false, // Disable the debug banner
  ));
}

class Community extends StatelessWidget {
  const Community({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Community',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        
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
            padding: EdgeInsets.symmetric(vertical: 16),
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
            // Main image or placeholder
            Positioned.fill(
              top: -20, // Move image slightly upwards
              child: imageWidget ?? Container(color: Colors.grey[300]),
            ),
            // Semi-transparent black overlay for contrast at the top
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.0),
              ),
            ),
            // Solid white bottom overlay for button and title
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(title: title, description: "Description of $title"),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange, // Light orange background
                        foregroundColor: Colors.white,
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
            ),
          ],
        ),
      ),
    );
  }
}
