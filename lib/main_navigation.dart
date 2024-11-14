import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'counter_page.dart';
import 'map_page.dart';
import 'profile_page.dart';
import 'mapsetting.dart';

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
      CounterPage(username: widget.username),
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
    _mapPageKey.currentState?.addRoute(routeName, routePoints); // MapPage의 addRoute 호출
    setState(() {
      _selectedIndex = 1; // Map 탭으로 전환
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.countertops),
            label: 'Counter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Map Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
