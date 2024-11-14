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
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId(routeName),
          points: routePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
    if (routePoints.isNotEmpty) {
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          _getLatLngBounds(routePoints),
          50.0,
        ),
      );
    }
  }

  LatLngBounds _getLatLngBounds(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (var point in points) {
      if (minLat == null || point.latitude < minLat) minLat = point.latitude;
      if (maxLat == null || point.latitude > maxLat) maxLat = point.latitude;
      if (minLng == null || point.longitude < minLng) minLng = point.longitude;
      if (maxLng == null || point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
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
