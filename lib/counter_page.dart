import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CounterPage extends StatefulWidget {
  final String username;

  const CounterPage({super.key, required this.username});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  late int _counter;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final userDoc = _firestore.collection("users").doc(widget.username);

    final docSnapshot = await userDoc.get();
    if (docSnapshot.exists) {
      setState(() {
        _counter = docSnapshot["counter"];
      });
    }
  }

  Future<void> _incrementCounter() async {
    setState(() {
      _counter++;
    });

    final userDoc = _firestore.collection("users").doc(widget.username);
    await userDoc.update({"counter": _counter});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.username}'s Counter"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Your counter value is:"),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _incrementCounter,
              child: const Text("Increment"),
            ),
          ],
        ),
      ),
    );
  }
}
