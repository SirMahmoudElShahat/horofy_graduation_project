import 'package:flutter/material.dart';

class Level7Screen extends StatefulWidget {
  const Level7Screen({super.key});

  @override
  State<Level7Screen> createState() => _Level7ScreenState();
}

class _Level7ScreenState extends State<Level7Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 7'),
      ),
      body: const Center(
        child: Text('This is Level 7 Screen'),
      ),
    );
  
  }
}