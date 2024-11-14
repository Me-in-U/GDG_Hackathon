import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdg_hackathon/map_combined.dart';
import 'package:gdg_hackathon/ranking.dart';
import 'package:gdg_hackathon/show_badges.dart';
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

  // 뒤로 가기 버튼을 위한 상태
  DateTime? _lastPressed;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(username: widget.username),
      Community(), // Added Community page
      MapCombined(username: widget.username),
      RankingPage(username: widget.username),
      ShowBadges(username: widget.username),
    ];
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
            _selectedIndex = 0; // 뒤로 가기 시 Home 탭으로 이동
          });
          return false; // 기본 뒤로 가기 동작 방지
        } else {
          // 현재 탭이 Home일 때
          final now = DateTime.now();
          if (_lastPressed == null || now.difference(_lastPressed!) > const Duration(seconds: 2)) {
            _lastPressed = now;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('한 번 더 누르면 앱이 종료됩니다.'),
                duration: Duration(seconds: 2),
              ),
            );
            return false; // 앱 종료 방지
          }
          SystemNavigator.pop(); // 앱 종료
          return true; // 앱 종료 허용
        }
      },
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.user,
                size: 23,
                color: Colors.black,
              ),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.users,
                size: 23,
                color: Colors.blue,
              ),
              label: '커뮤니티',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.map,
                size: 23,
                color: Colors.black,
              ),
              label: '지도',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.trophy,
                size: 23,
                color: Colors.amber,
              ),
              label: '랭킹',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.award,
                size: 23,
                color: Colors.deepOrange,
              ),
              label: '뱃지',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
