import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPage extends StatefulWidget {
  final String username;

  const MapPage({super.key, required this.username});

  @override
  State<MapPage> createState() => MapPageState(); // State 반환
}

class MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final List<Polyline> _routeSegments = []; // 경로 세그먼트
  final LatLng _defaultCenter = const LatLng(36.5, 127.5);
  List<LatLng> _routePoints = [];
  LatLng? _currentPosition;
  int _visitedSegmentsIndex = -1; // 방문한 세그먼트의 인덱스
  bool _started = false; // 시작 여부
  double _totalDistance = 0.0; // 총 이동 거리

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 중지
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _moveToCurrentLocation();
    _startTimedLocationUpdates(); // GPS 추적 시작
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

  void addRoute(String routeName, List<LatLng> routePoints) {
    if (routePoints.isEmpty) {
      return; // 빈 경로는 처리하지 않음
    }

    _routePoints = routePoints;
    _createRouteSegments(); // 경로를 세그먼트로 나눔

    // 경로의 첫 번째 좌표로 카메라 이동
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: routePoints.first,
          zoom: 15.0,
        ),
      ),
    );
  }

  void _createRouteSegments() {
    _routeSegments.clear(); // 기존 세그먼트 초기화

    for (int i = 0; i < _routePoints.length - 1; i++) {
      List<LatLng> interpolatedPoints = _interpolatePoints(
        _routePoints[i],
        _routePoints[i + 1],
        10.0, // 10미터 단위로 나눔
      );

      for (int j = 0; j < interpolatedPoints.length - 1; j++) {
        _routeSegments.add(
          Polyline(
            polylineId: PolylineId('segment_${i}_$j'),
            points: [interpolatedPoints[j], interpolatedPoints[j + 1]],
            color: Colors.blue, // 기본 색상
            width: 5,
          ),
        );
      }
    }

    setState(() {}); // 세그먼트 갱신
  }

  List<LatLng> _interpolatePoints(LatLng start, LatLng end, double stepDistance) {
    List<LatLng> points = [start]; // 시작점 추가
    double totalDistance = Geolocator.distanceBetween(
      start.latitude, start.longitude,
      end.latitude, end.longitude,
    );

    if (totalDistance <= stepDistance) {
      points.add(end); // 거리가 짧으면 바로 끝점 추가
      return points;
    }

    int numSteps = (totalDistance / stepDistance).floor();
    for (int i = 1; i <= numSteps; i++) {
      double fraction = (i * stepDistance) / totalDistance;
      double lat = start.latitude + (end.latitude - start.latitude) * fraction;
      double lng = start.longitude + (end.longitude - start.longitude) * fraction;
      points.add(LatLng(lat, lng));
    }

    points.add(end); // 끝점 추가
    return points;
  }

  void _startTimedLocationUpdates() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      _updateRouteProgress(currentLocation); // 경로 진행 상황 업데이트
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

    // 거리 계산 및 진행 업데이트
    if (_currentPosition != null) {
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        currentLocation.latitude,
        currentLocation.longitude,
      );
      _totalDistance += distance / 1000; // 거리 누적 (km 단위)
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
            _endRoute(); // 마지막 지점 도달 시 종료
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

    return (distanceToStart + distanceToEnd - segmentLength).abs() < 15.0; // 허용 오차
  }

  void _endRoute() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('경로 종료!')),
    );

    // Firestore 업데이트
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.username);
    await userDoc.update({
      'totalDistance': FieldValue.increment(_totalDistance), // 누적 거리 업데이트
    });

    _totalDistance = 0.0; // 거리 초기화
    _started = false;
    _visitedSegmentsIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Page'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _endRoute, // 종료 버튼
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _defaultCenter,
          zoom: 11.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        polylines: Set<Polyline>.of(_routeSegments),
      ),
    );
  }
}
