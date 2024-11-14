import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BadgePage extends StatelessWidget {
  const BadgePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3A8D99),
        title: Text('소유한 뱃지'),
        automaticallyImplyLeading: true, // Shows the back button
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to ProfilePage
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'SEPTEMBER 2022', // Title as in the image
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A8D99)),
            ),
            SizedBox(height: 10),
            // Status row (Active + 10 Days left)
            Row(
              children: [
                Text(
                  'Active + 10 Days left',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'BRONZE',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Progress bar
            LinearProgressIndicator(
              value: 5 / 7,  // Example progress (completed workouts / total workouts)
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 10),
            // Description
            Text(
              '5/7 workouts completed to next level',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // Description text
            Text(
              'Duis eu sed tortor euismod vestibulum. Vel nec sed gravida viverra id faucibus ipsum lectus.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 20),
            // Badges section
            Text(
              'Badges',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildBadges(context),  // Pass context to build badges
          ],
        ),
      ),
    );
  }

  Widget _buildBadges(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.33, // Set the height to one-third of the screen height
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
      ),
      child: GridView.count(
        crossAxisCount: 3, // Number of columns
        children: [
          _buildBadge(FontAwesomeIcons.running, 'Marathon', Colors.green),
          _buildBadge(FontAwesomeIcons.dumbbell, 'Strength', Colors.blue),
          _buildBadge(FontAwesomeIcons.trophy, 'Winner', Colors.amber),
          _buildBadge(FontAwesomeIcons.heartbeat, 'Endurance', Colors.red),
          _buildBadge(FontAwesomeIcons.shoePrints, 'Tracker', Colors.purple),
          _buildBadge(FontAwesomeIcons.skiing, 'Winter Run', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String title, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 40,
          color: color,  // Badge color
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String username;

  const ProfilePage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3A8D99),
        title: Text(
          'Profile',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Top header section with image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,  // Height of the top section
              decoration: BoxDecoration(
                color: Color(0xFF3A8D99),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Text(
                  'SEPTEMBER SPRINTER',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          // Content starts after the top header
          Padding(
            padding: const EdgeInsets.only(top: 150.0, left: 16.0, right: 16.0), // Adjusted padding to not overlap
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
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
}

void main() {
  runApp(MaterialApp(
    home: ProfilePage(username: 'John Doe'),
  ));
}
