// lib/tutorial_no_ar_page.dart
import 'package:flutter/material.dart';

class NoArTutorialPage extends StatelessWidget {
  const NoArTutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("3D Viewer Tutorial")),
      body: const Center(
        child: Text(
          "Your device does not support AR.\nYou can still view furniture in 3D mode.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

