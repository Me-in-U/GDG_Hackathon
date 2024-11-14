import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'counter_page.dart';
import 'map_page.dart';
import 'profile_page.dart';
import 'mapsetting.dart';
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

  final GlobalKey<MapPageState> _mapPageKey = GlobalKey(); // GlobalKey 추가
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(username: widget.username),
      MapPage(key: _mapPageKey, username: widget.username), // GlobalKey 전달
      const ProfilePage(),
      MapSettingPage(
        username: widget.username,
        loadRouteToMap: loadRouteToMap, // MapSettingPage에 함수 전달
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void loadRouteToMap(String routeName, List<LatLng> routePoints) {
    // MapPage로 이동
    setState(() {
      _selectedIndex = 1; // Map 탭으로 전환
    });

    // MapPage가 완전히 렌더링된 후에 addRoute 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mapPageKey.currentState == null) {
        return;
      }
      if (routePoints.isEmpty) {
        return;
      }
      _mapPageKey.currentState?.addRoute(routeName, routePoints); // MapPage의 addRoute 호출
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
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Map Settings',
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
