import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MapSettingPage extends StatefulWidget {
  final String username;
  final Function(String routeName, List<LatLng> routePoints) loadRouteToMap;

  const MapSettingPage({
    super.key,
    required this.username,
    required this.loadRouteToMap,
  });

  @override
  State<MapSettingPage> createState() => _MapSettingPageState();
}

class _MapSettingPageState extends State<MapSettingPage> {
  late GoogleMapController mapController;
  final List<LatLng> _routePoints = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _locateMe();
  }

  Future<void> _locateMe() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  void _addPoint(LatLng point) {
    setState(() {
      _routePoints.add(point);
    });
  }

  Future<void> _saveRoute(String routeName) async {
    if (_routePoints.isEmpty) {
      Fluttertoast.showToast(
        msg: "경로에 추가된 위치가 없습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    final routeData = _routePoints
        .map((point) => {"lat": point.latitude, "lng": point.longitude})
        .toList();

    await _firestore.collection("routes").doc(routeName).set({"points": routeData});
    Fluttertoast.showToast(
      msg: 'Route "$routeName" saved successfully!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    setState(() {
      _routePoints.clear();
    });
  }

  Future<void> _loadRoute(String routeName) async {
    final routeDoc =
    await _firestore.collection("routes").doc(routeName).get();

    if (routeDoc.exists) {
      final List<dynamic> points = routeDoc['points'];
      final List<LatLng> routePoints =
      points.map((e) => LatLng(e['lat'], e['lng'])).toList();

      // Toast로 경로 이름과 점 수 표시
      Fluttertoast.showToast(
        msg: 'Route "$routeName" loaded with ${routePoints.length} points!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      widget.loadRouteToMap(routeName, routePoints); // MainNavigation에 전달
      print("Route $routeName loaded with ${routePoints.length} points."); // 디버깅 로그
    } else {
      Fluttertoast.showToast(
        msg: 'Route "$routeName" does not exist.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Settings'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(36.5, 127.5), // 대한민국 중심 좌표
                zoom: 11.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onLongPress: _addPoint, // 길게 눌러 경로 추가
              polylines: {
                Polyline(
                  polylineId: const PolylineId('newRoute'),
                  points: _routePoints,
                  color: Colors.red,
                  width: 5,
                ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final TextEditingController nameController =
                      TextEditingController();
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Save Route"),
                            content: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: "Route Name",
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _saveRoute(nameController.text.trim());
                                },
                                child: const Text("Save"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text("Save Route"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final routesSnapshot = await _firestore.collection("routes").get();
                      final routes = routesSnapshot.docs.map((doc) => doc.id).toList();

                      await showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            title: const Text("Select a Route"),
                            children: routes.map((route) {
                              return SimpleDialogOption(
                                child: Text(route),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _loadRoute(route); // 선택한 경로 로드
                                },
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                    child: const Text("Load Route"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
