import 'package:flutter/material.dart';
import 'package:gdg_hackathon/map_combined.dart';
import 'package:gdg_hackathon/ranking.dart';
import 'community.dart';
import 'home_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainNavigation extends StatefulWidget {
  final String username;
  const MainNavigation({super.key, required this.username});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(username: widget.username),
      Community(), // Added Community page
      MapCombined(username: widget.username), // GlobalKey 전달
      RankingPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.user,
              size: 23, // 원하는 크기로 설정
              color: Colors.black, // 원하는 색상으로 설정
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.users, // Icon for Community
              size: 23,
              color: Colors.blue, // Icon color for Community
            ),
            label: 'Community', // Label for Community
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.map,
              size: 23, // 원하는 크기로 설정
              color: Colors.black, // 원하는 색상으로 설정
            ),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.trophy,
              size: 23, // 원하는 크기로 설정
              color: Colors.amber, // 원하는 색상으로 설정
            ),
            label: 'Ranking',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
