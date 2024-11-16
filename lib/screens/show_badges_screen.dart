import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';

class ShowBadgesScreen extends StatefulWidget {
  final String username;

  const ShowBadgesScreen({super.key, required this.username});

  @override
  State<ShowBadgesScreen> createState() => _ShowBadgesScreenState();
}

class _ShowBadgesScreenState extends State<ShowBadgesScreen> with SingleTickerProviderStateMixin {
  final List<Badge> _badges = [];
  final List<_BadgePhysics> _badgePhysics = [];
  late Ticker _ticker;

  bool _isLoading = true; // 추가: 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_updatePhysics)..start();
    _fetchBadges();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _fetchBadges() async {
    try {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(widget.username).get();
      final List<dynamic> badgeNames = userDoc['badges'];

      for (String badgeName in badgeNames) {
        final badgeDoc =
        await FirebaseFirestore.instance.collection('routes').doc(badgeName).get();
        if (badgeDoc.exists) {
          final imageBase64 = badgeDoc['image'] as String?;
          if (imageBase64 != null) {
            final badge = Badge(
              name: badgeName,
              image: base64Decode(imageBase64),
              color: _generateRandomColor(),
            );
            _badges.add(badge);
          }
        }
      }

      _initializeBadgePhysics();
    } catch (e) {
      print('Error fetching badges: $e');
    } finally {
      setState(() {
        _isLoading = false; // 로딩 완료
      });
    }
  }

  void _initializeBadgePhysics() {
    final size = MediaQuery.of(context).size;
    const badgeSize = 50.0;
    final random = Random();

    for (final badge in _badges) {
      Offset position;
      bool isValid;

      // Find a valid position that doesn't overlap with existing badges
      do {
        isValid = true;
        position = Offset(
          random.nextDouble() * (size.width - badgeSize),
          -badgeSize - random.nextDouble() * 100,
        );

        for (final otherBadge in _badgePhysics) {
          final dx = position.dx - otherBadge.position.dx;
          final dy = position.dy - otherBadge.position.dy;
          final distance = sqrt(dx * dx + dy * dy);

          if (distance < badgeSize) {
            isValid = false;
            break;
          }
        }
      } while (!isValid);

      // Add badge physics
      _badgePhysics.add(
        _BadgePhysics(
          position: position,
          velocity: Offset(random.nextDouble() * 3 - 1, random.nextDouble() * 3 + 1),
        ),
      );
    }
  }

  void _updatePhysics(Duration elapsed) {
    final double dt = 1 / 60;
    final size = MediaQuery.of(context).size;
    final double groundHeight = _calculateGroundHeight();

    setState(() {
      for (int i = 0; i < _badgePhysics.length; i++) {
        final badge = _badgePhysics[i];

        badge.position += badge.velocity * dt;

        // Boundary collision
        if (badge.position.dx < 0 || badge.position.dx > size.width - 50) {
          badge.velocity = Offset(-badge.velocity.dx, badge.velocity.dy);
          badge.position = Offset(
            badge.position.dx.clamp(0, size.width - 50),
            badge.position.dy,
          );
        }
        if (badge.position.dy > size.height - groundHeight - 50) {
          badge.velocity = Offset(badge.velocity.dx, -badge.velocity.dy * 0.8);
          badge.position = Offset(badge.position.dx, size.height - groundHeight - 50);
        }

        // Gravity 9.8 -> 20
        badge.velocity += Offset(0, 20 * dt);

        // Collision detection and response
        for (int j = i + 1; j < _badgePhysics.length; j++) {
          final other = _badgePhysics[j];
          final dx = badge.position.dx - other.position.dx;
          final dy = badge.position.dy - other.position.dy;
          final distance = sqrt(dx * dx + dy * dy);

          if (distance < 50) {
            final normal = Offset(dx / distance, dy / distance);
            final relativeVelocity = badge.velocity - other.velocity;
            final dotProduct = relativeVelocity.dx * normal.dx +
                relativeVelocity.dy * normal.dy;

            if (dotProduct < 0) {
              final impulse = normal * (2 * dotProduct / 2);
              badge.velocity -= impulse;
              other.velocity += impulse;
            }
          }
        }
      }
    });
  }

  double _calculateGroundHeight() {
    return 150 + MediaQuery.of(context).padding.bottom;
  }

  Color _generateRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소유한 뱃지'),
        backgroundColor: Colors.greenAccent,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(), // 로딩 중에 표시할 UI
      )
          : Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.lightBlueAccent,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: _calculateGroundHeight(),
              color: Colors.green,
            ),
          ),
          ..._badges.asMap().entries.map((entry) {
            final index = entry.key;
            final badge = entry.value;
            final badgePhysics = _badgePhysics[index];

            return Positioned(
              left: badgePhysics.position.dx,
              top: badgePhysics.position.dy,
              child: BadgeWidget(badge: badge),
            );
          }),
        ],
      ),
    );
  }
}

class Badge {
  final String name;
  final Uint8List image;
  final Color color;

  Badge({required this.name, required this.image, required this.color});
}

class _BadgePhysics {
  Offset position;
  Offset velocity;

  _BadgePhysics({required this.position, required this.velocity});
}

class BadgeWidget extends StatelessWidget {
  final Badge badge;

  const BadgeWidget({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Colors.white, badge.color],
          center: const Alignment(-0.3, -0.3),
          radius: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: ClipOval(
          child: Image.memory(
            badge.image,
            fit: BoxFit.cover,
            width: 40,
            height: 40,
          ),
        ),
      ),
    );
  }
}
