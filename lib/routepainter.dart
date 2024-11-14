import 'package:flutter/material.dart';

class RoutePainter extends CustomPainter {
  final List<Map<String, double>> routeData;

  RoutePainter(this.routeData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < routeData.length - 1; i++) {
      final point1 = Offset(routeData[i]['lng']!, routeData[i]['lat']!);
      final point2 = Offset(routeData[i + 1]['lng']!, routeData[i + 1]['lat']!);
      canvas.drawLine(point1, point2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}