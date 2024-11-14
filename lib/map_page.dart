import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  final String username;

  const MapPage({super.key, required this.username});

  @override
  State<MapPage> createState() => MapPageState(); // State 반환
}

class MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final List<Polyline> _polylines = [];
  final LatLng _defaultCenter = const LatLng(36.5, 127.5);
  LatLng? _currentPosition;

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

  void addRoute(String routeName, List<LatLng> routePoints) {
    if (routePoints.isEmpty) {
      return; // 빈 경로는 처리하지 않음
    }

    setState(() {
      // Polyline 추가
      _polylines.add(
        Polyline(
          polylineId: PolylineId(routeName),
          points: routePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    });

    // 경로의 첫 번째 좌표로 카메라 이동
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: routePoints.first,
          zoom: 15.0, // 확대 수준 설정
        ),
      ),
    );
  }


  LatLngBounds _getLatLngBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Page'),
        backgroundColor: Colors.green[700],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _defaultCenter,
          zoom: 11.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        polylines: Set<Polyline>.of(_polylines),
      ),
    );
  }
}
