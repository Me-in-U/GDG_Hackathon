import 'package:flutter/material.dart';

class RoutePainter extends CustomPainter {
  final List<Map<String, double>> routeData;

  RoutePainter(this.routeData);

  @override
  void paint(Canvas canvas, Size size) {
    // 화면에 맞게 경로의 크기를 스케일링하기 위해 최대/최소 경도와 위도를 구합니다.
    double minLat = double.infinity;
    double maxLat = double.negativeInfinity;
    double minLng = double.infinity;
    double maxLng = double.negativeInfinity;

    // 경로 데이터에서 최솟값과 최댓값을 구합니다.
    for (var point in routeData) {
      minLat = point['lat']! < minLat ? point['lat']! : minLat;
      maxLat = point['lat']! > maxLat ? point['lat']! : maxLat;
      minLng = point['lng']! < minLng ? point['lng']! : minLng;
      maxLng = point['lng']! > maxLng ? point['lng']! : maxLng;
    }

    // 위도/경도 값을 화면 좌표에 맞게 변환합니다.
    double latRange = maxLat - minLat;
    double lngRange = maxLng - minLng;

    // 화면 크기보다 조금 더 작은 비율로 경로를 조정 (여유 공간을 적당히 추가)
    double padding = 0.3; // 여유 공간을 30%로 설정
    double latScale = (1 - padding) * size.height / latRange;
    double lngScale = (1 - padding) * size.width / lngRange;

    // 화면의 중앙에 경로가 오도록 오프셋 계산
    double offsetX = (size.width * padding) / 2;
    double offsetY = (size.height * padding) / 2;

    // 화면의 크기에 맞게 경도/위도를 비례적으로 변환하는 함수
    Offset scaleToCanvas(double lat, double lng) {
      double x = (lng - minLng) * lngScale + offsetX; // 경도를 화면 너비에 맞게 변환
      double y = size.height - (lat - minLat) * latScale - offsetY; // 위도를 화면 높이에 맞게 변환
      return Offset(x, y);
    }

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    // 경로를 그립니다.
    for (int i = 0; i < routeData.length - 1; i++) {
      final point1 = scaleToCanvas(routeData[i]['lat']!, routeData[i]['lng']!);
      final point2 = scaleToCanvas(routeData[i + 1]['lat']!, routeData[i + 1]['lng']!);
      canvas.drawLine(point1, point2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}