import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:gdg_hackathon/routepainter.dart';
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

    final boundary = GlobalKey();  // RepaintBoundary의 key

    // RepaintBoundary를 사용하여 경로를 그린 화면을 캡처
    final boundaryWidget = RepaintBoundary(
      key: boundary,
      child: CustomPaint(
        size: Size(double.infinity, 400),
        painter: RoutePainter(routeData),
      ),
    );

    // 로딩 중인 아이콘과 함께 표시
    final loadingWidget = Stack(
      children: [
        Center(child: boundaryWidget),  // 캡처할 위젯
        Center(child: CircularProgressIndicator()),  // 로딩 중 아이콘
      ],
    );

    // 화면에 위젯 띄우기 (사이즈 조정 후 로딩 아이콘 추가)
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            width: 100,  // 너비 설정
            height: 100, // 높이 설정
            child: loadingWidget, // 로딩 화면을 작은 박스 안에 배치
          ),
        );
      },
    );

    // 일정 시간 뒤 자동으로 닫기
    await Future.delayed(Duration(milliseconds: 500));

    final RenderRepaintBoundary renderBoundary = boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await renderBoundary.toImage(pixelRatio: 3.0);

    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    // 다이얼로그 닫기
    Navigator.of(context).pop();

    await _firestore.collection("routes").doc(routeName).set({"points": routeData, "image":base64Encode(buffer)});
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
