import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  final String title; // Route title
  final String description; // Route description

  const DetailPage({Key? key, required this.title, required this.description})
      : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Color buttonColor = Colors.deepOrange; // Default button color
  bool isParticipating = false; // Participation status
  String? routeImage; // Base64 image data from Firestore

  @override
  void initState() {
    super.initState();
    _fetchRouteImage(); // Load the route image when the page initializes
  }

  // Toggle participation status and save route
  void _toggleButtonState() async {
    if (isParticipating) {
      // Cancel participation
      setState(() {
        buttonColor = Colors.deepOrange;
        isParticipating = false;
      });
    } else {
      // Participate in the route
      setState(() {
        buttonColor = Colors.blue;
        isParticipating = true;
      });

      // Save the selected route
      await _saveSelectedRoute();

      if (mounted) {
        // Close the current page and return the route name
        Navigator.pop(context, widget.title);
      }
    }
  }

  // Fetch the route image from Firestore
  Future<void> _fetchRouteImage() async {
    try {
      final routeDoc = await FirebaseFirestore.instance
          .collection('routes')
          .doc(widget.title)
          .get();

      if (routeDoc.exists && routeDoc['image'] != null) {
        setState(() {
          routeImage = routeDoc['image']; // Load Base64 image data
        });
      }
    } catch (e) {
      print('Error fetching route image: $e');
    }
  }

  // Save the selected route to Firestore
  Future<void> _saveSelectedRoute() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('selectedRoute') // Replace with user-specific document if needed
          .set({'routeName': widget.title}, SetOptions(merge: true));
    } catch (e) {
      print('Error saving selected route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background color
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Custom back button color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRouteImage(), // Display route image
            const SizedBox(height: 20),
            _buildRouteDetails(), // Route details and participation button
          ],
        ),
      ),
    );
  }

  // Build route image container
  Widget _buildRouteImage() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: routeImage != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.memory(
          base64Decode(routeImage!), // Decode Base64 and display
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Build route details and participation button
  Widget _buildRouteDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStartEndPoints(), // Start and end points
          const SizedBox(height: 20),
          _buildAdditionalInfo(), // Additional information (e.g., distance, calories)
          const SizedBox(height: 20),
          _buildParticipationButton(), // Join/Cancel button
        ],
      ),
    );
  }

  // Build start and end points
  Widget _buildStartEndPoints() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPointInfo(Icons.location_on, '출발점', widget.title),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.5, // Adjust this for progress (0.0 to 1.0)
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
        _buildPointInfo(Icons.flag, '도착점', widget.description),
      ],
    );
  }

  // Build single point info (start or end)
  Widget _buildPointInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: icon == Icons.location_on ? Colors.green : Colors.red),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  // Build additional information (distance, calories)
  Widget _buildAdditionalInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoBox('3.5', 'Kilometer'),
        _buildInfoBox('1.7k', 'Calories'),
        _buildInfoBox('...', 'More'),
      ],
    );
  }

  // Build single info box
  Widget _buildInfoBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Build participation button
  Widget _buildParticipationButton() {
    return GestureDetector(
      onTap: _toggleButtonState,
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          isParticipating ? '참여취소' : '참여하기',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
