import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gdg_hackathon/routepainter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MapCombined extends StatefulWidget {
  final String username;

  const MapCombined({super.key, required this.username});

  @override
  State<MapCombined> createState() => _MapCombinedState();
}

class _MapCombinedState extends State<MapCombined> {
  late GoogleMapController mapController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // General States
  bool _isDrawing = false; // Drawing Mode
  bool _routeLoaded = false; // Route Loaded
  bool _started = false; // Tracking started
  double _totalDistance = 0.0; // 총 이동 거리
  double _currentProgress = 0.0; // 현재 진행 거리
  double _routeLength = 0.0; // 전체 경로 길이
  int _visitedSegmentsIndex = -1; // 마지막 방문한 세그먼트

  // Map and Route States
  final List<Polyline> _routeSegments = []; // 경로 세그먼트
  final List<LatLng> _drawnPoints = []; // 사용자가 그리고 있는 점
  final Set<Marker> _markers = {}; // Markers for start and end points
  final LatLng _defaultCenter = const LatLng(36.5, 127.5); // 기본 지도 위치
  List<LatLng> _routePoints = []; // 로드된 경로의 점들
  LatLng? _currentPosition;

  Polyline? _drawnRoute; // Current drawn route polyline
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _moveToCurrentLocation();
    _startTimedLocationUpdates();
  }

  Future<void> _moveToCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentPosition = LatLng(position.latitude, position.longitude);
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition!,
          zoom: 15.0,
        ),
      ),
    );
  }

  // **1. Draw Route 기능**
  // Add a Polyline for the drawn route
  void _addPoint(LatLng point) {
    if (_isDrawing) {
      setState(() {
        _drawnPoints.add(point); // Add point to the list

        // Update the drawn route polyline
        _drawnRoute = Polyline(
          polylineId: const PolylineId('drawnRoute'),
          points: _drawnPoints,
          color: Colors.red, // Set color for the drawn route
          width: 5, // Set line width
        );

        // Add marker at the start of the route
        if (_drawnPoints.length == 1) {
          _markers.add(Marker(
            markerId: const MarkerId('startMarker'),
            position: point,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
            infoWindow: const InfoWindow(title: '출발'),
          ));
        }
      });
    }
  }

  void _cancelDrawing() {
    setState(() {
      _isDrawing = false;
      _drawnPoints.clear();
      _drawnRoute = null;
      _markers.clear();
    });
    Fluttertoast.showToast(
      msg: "그리기가 취소되었습니다.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
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

  // **2. Load Route 기능**
  Future<void> _loadRoute(String routeName) async {
    final routeDoc = await FirebaseFirestore.instance.collection("routes").doc(routeName).get();

    if (routeDoc.exists) {
      final List<dynamic> points = routeDoc['points'];
      final List<LatLng> routePoints = points.map((e) => LatLng(e['lat'], e['lng'])).toList();

      setState(() {
        _routePoints = routePoints;
        _routeLoaded = true; // Route loaded
        _createRouteSegments();
        _calculateRouteLength(); // 전체 경로 길이 계산
        _moveToRouteStart();
        // Add start and end markers
        _markers
          ..clear()
          ..add(Marker(
            markerId: const MarkerId('startMarker'),
            position: _routePoints.first,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
            infoWindow: const InfoWindow(title: '출발'),
          ))
          ..add(Marker(
            markerId: const MarkerId('endMarker'),
            position: _routePoints.last,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: '도착'),
          ));
      });
    } else {
      Fluttertoast.showToast(
        msg: 'Route "$routeName" does not exist.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
  void _moveToRouteStart() {
    if (_routePoints.isNotEmpty) {
      // Move the camera to the first point of the route
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _routePoints.first, // First point of the route
            zoom: 15.0, // Zoom level
          ),
        ),
      );
    }
  }


  void _createRouteSegments() {
    _routeSegments.clear(); // 기존 세그먼트 초기화

    for (int i = 0; i < _routePoints.length - 1; i++) {
      List<LatLng> interpolatedPoints = _interpolatePoints(
        _routePoints[i],
        _routePoints[i + 1],
        10.0, // 10-meter segments
      );

      for (int j = 0; j < interpolatedPoints.length - 1; j++) {
        _routeSegments.add(
          Polyline(
            polylineId: PolylineId('segment_${i}_$j'),
            points: [interpolatedPoints[j], interpolatedPoints[j + 1]],
            color: Colors.blue,
            width: 5,
          ),
        );
      }
    }setState(() {}); // 세그먼트 갱신
  }

  void _calculateRouteLength() {
    _routeLength = 0.0;
    for (int i = 0; i < _routePoints.length - 1; i++) {
      _routeLength += Geolocator.distanceBetween(
        _routePoints[i].latitude,
        _routePoints[i].longitude,
        _routePoints[i + 1].latitude,
        _routePoints[i + 1].longitude,
      );
    }
    _routeLength /= 1000; // Convert to kilometers
  }

  List<LatLng> _interpolatePoints(LatLng start, LatLng end, double stepDistance) {
    List<LatLng> points = [start];
    double totalDistance = Geolocator.distanceBetween(
      start.latitude, start.longitude,
      end.latitude, end.longitude,
    );

    if (totalDistance <= stepDistance) {
      points.add(end);
      return points;
    }

    int numSteps = (totalDistance / stepDistance).floor();
    for (int i = 1; i <= numSteps; i++) {
      double fraction = (i * stepDistance) / totalDistance;
      double lat = start.latitude + (end.latitude - start.latitude) * fraction;
      double lng = start.longitude + (end.longitude - start.longitude) * fraction;
      points.add(LatLng(lat, lng));
    }

    points.add(end);
    return points;
  }

  // **3. 거리 추적 업데이트**
  void _startTimedLocationUpdates() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      _updateRouteProgress(currentLocation);
    });
  }

  void _updateRouteProgress(LatLng currentLocation) {
    if (_routePoints.isEmpty) return;

    // 시작 지점에 도달 여부 확인
    if (!_started) {
      double distanceToStart = Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        _routePoints.first.latitude,
        _routePoints.first.longitude,
      );

      if (distanceToStart <= 20.0) { // 시작 반경 20m
        _started = true;
        ScaffoldMessenger.of(context).clearSnackBars(); // 모든 기존 토스트 제거
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('경로 시작!')),
        );
      } else {
        return; // 시작하지 않았으면 진행하지 않음
      }
    }

    if (_currentPosition != null) {
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        currentLocation.latitude,
        currentLocation.longitude,
      );
      _totalDistance += distance / 1000;
      _currentProgress = (_totalDistance / _routeLength).clamp(0.0, 1.0); // Progress as ratio
    }
    _currentPosition = currentLocation;

    for (int i = _visitedSegmentsIndex + 1; i < _routeSegments.length; i++) {
      Polyline segment = _routeSegments[i];
      LatLng start = segment.points.first;
      LatLng end = segment.points.last;

      if (_isOnSegment(currentLocation, start, end)) {
        setState(() {
          _routeSegments[i] = segment.copyWith(colorParam: Colors.red);
          _visitedSegmentsIndex = i;

          if (i == _routeSegments.length - 1) {
            _endRoute();
          }
        });
        break;
      }
    }
  }

  bool _isOnSegment(LatLng point, LatLng start, LatLng end) {
    double distanceToStart = Geolocator.distanceBetween(
        point.latitude, point.longitude, start.latitude, start.longitude);
    double distanceToEnd = Geolocator.distanceBetween(
        point.latitude, point.longitude, end.latitude, end.longitude);
    double segmentLength = Geolocator.distanceBetween(
        start.latitude, start.longitude, end.latitude, end.longitude);

    return (distanceToStart + distanceToEnd - segmentLength).abs() < 15.0;
  }

  // **4. 루트 종료/정지**
  void _endRoute() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('경로 종료!')),
    );

    await FirebaseFirestore.instance.collection('users').doc(widget.username).update({
      'totalDistance': FieldValue.increment(_totalDistance),
    });

    setState(() {
      _routeLoaded = false;
      _markers.clear();
      _routeSegments.clear();
      _routePoints.clear();
      _totalDistance = 0.0;
      _currentProgress = 0.0;
      _visitedSegmentsIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _defaultCenter,
              zoom: 11.0,
            ),
            zoomControlsEnabled: false, // 기본 확대/축소 버튼 비활성화
            myLocationButtonEnabled: false, // 기본 위치 버튼 비활성화
            polylines: {
              if (_drawnRoute != null) _drawnRoute!,
              ..._routeSegments, // Include the route segments for loaded routes
            },
            onLongPress: _addPoint,
            markers: _markers,
          ),
          // 커스텀 버튼
          Positioned(
            bottom: 130,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _moveToCurrentLocation,
                  child: const Icon(Icons.my_location, color: Colors.black),
                ),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    mapController.animateCamera(CameraUpdate.zoomIn());
                  },
                  child: const Icon(Icons.add, color: Colors.black),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    mapController.animateCamera(CameraUpdate.zoomOut());
                  },
                  child: const Icon(Icons.remove, color: Colors.black),
                ),
              ],
            ),
          ),
          if (_routeLoaded)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white70,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: _currentProgress,
                      backgroundColor: Colors.grey[300],
                      color: Colors.deepPurple,
                      minHeight: 10.0,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '현재 거리: ${_totalDistance.toStringAsFixed(2)} km / 총 거리: ${_routeLength.toStringAsFixed(2)} km',
                      style: const TextStyle(fontSize: 16),
                    ),
                    ElevatedButton(
                      onPressed: _endRoute,
                      child: const Text('중단'),
                    ),
                  ],
                ),
              ),
            ),
          if (!_routeLoaded)
            Positioned(
              bottom: 25, // 기존보다 약간 더 높은 위치
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isDrawing
                        ? _cancelDrawing
                        : () {
                      setState(() => _isDrawing = true);
                      Fluttertoast.showToast(
                        msg: "지도를 길게 눌러 경로를 그려보세요",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    },
                    child: Text(_isDrawing ? 'Cancel Draw' : 'Draw Route'),
                  ),
                  ElevatedButton(
                    onPressed: !_isDrawing
                        ? () async{
                      final routesSnapshot =
                      await FirebaseFirestore.instance.collection("routes").get();
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
                                    _loadRoute(route);
                                  },
                                );
                              }).toList(),
                            );
                          }
                      );
                    }
                        : () async {
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
                    child: Text(_isDrawing ?'Save Route': 'Load Route'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
