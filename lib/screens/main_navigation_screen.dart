import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdg_hackathon/screens/map_screen.dart';
import 'package:gdg_hackathon/screens/ranking_screen.dart';
import 'package:gdg_hackathon/screens/show_badges_screen.dart';
import 'community_screen.dart';
import 'community_stop_screen.dart';
import 'home_page_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainNavigationScreen extends StatefulWidget {
  final String username;

  const MainNavigationScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  final GlobalKey<MapScreenState> _mapKey = GlobalKey<MapScreenState>();

  DateTime? _lastPressed;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePageScreen(username: widget.username),
      CommunityScreen(onRouteSelected: _onRouteSelected),
      CommunityStopScreen(onRouteSelected: _onRouteSelected),
      MapScreen(key: _mapKey, username: widget.username),
      RankingScreen(username: widget.username),
      ShowBadgesScreen(username: widget.username),
    ];
  }

  Future<void> _onRouteSelected(String routeName) async {
    setState(() {
      _selectedIndex = 3; // Navigate to MapCombined
    });
    await Future.delayed(const Duration(milliseconds: 300));
    _mapKey.currentState?.loadRoute(routeName); // Call the exposed method
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        } else {
          final now = DateTime.now();
          if (_lastPressed == null ||
              now.difference(_lastPressed!) > const Duration(seconds: 2)) {
            _lastPressed = now;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('한 번 더 누르면 앱이 종료됩니다.'),
                duration: Duration(seconds: 2),
              ),
            );
            return false;
          }
          SystemNavigator.pop();
          return true;
        }
      },
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.user, size: 23, color: Colors.black),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.users, size: 23, color: Colors.blue),
              label: '커뮤니티',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.users, size: 23, color: Colors.blue),
              label: 'Stop 커뮤니티',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.map, size: 23, color: Colors.green),
              label: '지도',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.trophy, size: 23, color: Colors.amber),
              label: '랭킹',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.award, size: 23, color: Colors.deepOrange),
              label: '뱃지',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
