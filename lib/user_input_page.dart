import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_navigation.dart';

class UserInputPage extends StatefulWidget {
  const UserInputPage({super.key});

  @override
  State<UserInputPage> createState() => _UserInputPageState();
}

class _UserInputPageState extends State<UserInputPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _proceedToMainNavigation(String username) async {
    final userDoc = _firestore.collection("users").doc(username);

    // Firestore에서 사용자 데이터 확인 및 생성
    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set({"totalDistance": 0.0}); // 새 사용자 생성
    }

    // 페이지 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigation(username: username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("이름을 입력해 주세요"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: "이름",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final username = _controller.text.trim();
                  if (username.isNotEmpty) {
                    _proceedToMainNavigation(username);
                  }
                },
                child: const Text("로그인"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
