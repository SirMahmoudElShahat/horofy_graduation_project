import 'package:flutter/material.dart';

class Level5Screen extends StatefulWidget {
  const Level5Screen({super.key});

  @override
  State<Level5Screen> createState() => _Level5ScreenState();
}

class _Level5ScreenState extends State<Level5Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 5'),
      ),
      body: const Center(
        child: Text('This is Level 5 Screen'),
      ),
    );
  }
}