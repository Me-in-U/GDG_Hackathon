import 'dart:async';
import 'package:flutter/material.dart';
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
  final LatLng _defaultCenter = const LatLng(36.5, 127.5); // 기본 지도 위치
  List<LatLng> _routePoints = []; // 로드된 경로의 점들
  LatLng? _currentPosition;

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _moveToCurrentLocation();
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
  Polyline? _drawnRoute; // Current drawn route polyline
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
      });
    }
  }

  Future<void> _saveRoute(String routeName) async {
    if (_drawnPoints.isEmpty) {
      Fluttertoast.showToast(
        msg: "경로에 추가된 위치가 없습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    final routeData = _drawnPoints
        .map((point) => {"lat": point.latitude, "lng": point.longitude})
        .toList();

    await FirebaseFirestore.instance.collection("routes").doc(routeName).set({"points": routeData});
    Fluttertoast.showToast(
      msg: 'Route "$routeName" saved successfully!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    setState(() {
      _isDrawing = false; // 드로잉 종료
      _drawnPoints.clear();
      _drawnRoute = null; // Clear the polyline from the map
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
    _routeSegments.clear();

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
    }
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
    if (!_routeLoaded || _routePoints.isEmpty) return;

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
      appBar: AppBar(
        title: const Text('Route Manager'),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (_routeLoaded || _isDrawing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                final TextEditingController nameController = TextEditingController();
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
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _defaultCenter,
              zoom: 11.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            polylines: {
              if (_drawnRoute != null) _drawnRoute!,
              ..._routeSegments, // Include the route segments for loaded routes
            },
            onLongPress: _addPoint,
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
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => _isDrawing = true),
                    child: const Text('Draw Route'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
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
                        },
                      );
                    },
                    child: const Text('Load Route'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
