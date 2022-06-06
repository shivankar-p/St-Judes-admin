import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  @override
  TestScreenState createState() {
    return new TestScreenState();
  }
}

class TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
          const Text(
            'Have you been associated with St. Judes before?',
          ),
        ])));
  }
}