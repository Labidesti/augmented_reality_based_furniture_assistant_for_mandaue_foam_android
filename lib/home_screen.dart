// lib/home_screen.dart

import 'package:augmented_reality_based_furniture_assistant_for_mandaue_foam_android/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

// A simple data class for our furniture items
class Furniture {
  final String name;
  final String thumbnail; // Path to a thumbnail image
  final String modelPath; // Path to the .sfb 3D model

  Furniture({required this.name, required this.thumbnail, required this.modelPath});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ArCoreController arCoreController;

  // This will hold the path to the currently selected furniture model
  String? _selectedModelPath;

  // Let's create a list of furniture. Later, you can load this from Firebase!
  // NOTE: Make sure you have these assets in your project folder.
  // I'm using placeholder paths. Replace them with your actual asset paths.
  final List<Furniture> furnitureItems = [
    Furniture(name: 'Chair', thumbnail: 'assets/thumbnails/chair.png', modelPath: 'assets/models/chair.sfb'),
    Furniture(name: 'Sofa', thumbnail: 'assets/thumbnails/sofa.png', modelPath: 'assets/models/sofa.sfb'),
    Furniture(name: 'Table', thumbnail: 'assets/thumbnails/table.png', modelPath: 'assets/models/table.sfb'),
  ];

  @override
  void initState() {
    super.initState();
    // Pre-select the first item
    if (furnitureItems.isNotEmpty) {
      _selectedModelPath = furnitureItems.first.modelPath;
    }
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onNodeTap = (name) => print("Tapped node $name");
    arCoreController.onPlaneTap = _handleOnPlaneTap;
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    if (_selectedModelPath == null) {
      // No model selected, do nothing
      return;
    }
    final hit = hits.first;
    _addModel(hit);
  }

  void _addModel(ArCoreHitTestResult hit) {
    final node = ArCoreReferenceNode(
      name: _selectedModelPath!.split('/').last, // Use the file name as the node name
      object3DFileName: _selectedModelPath,
      position: hit.pose.translation,
      rotation: hit.pose.rotation,
      scale: vector.Vector3(1.0, 1.0, 1.0), // You can adjust the initial scale
    );
    arCoreController.addArCoreNodeWithAnchor(node);
  }

  void _logout() async {
    await AuthService().signOut();
    // The AuthWrapper will handle navigation
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AR Furniture Assistant"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          ArCoreView(
            onArCoreViewCreated: _onArCoreViewCreated,
            enableTapRecognizer: true,
          ),
          _buildFurnitureSelector(),
        ],
      ),
    );
  }

  // This widget builds the horizontal list of furniture at the bottom
  Widget _buildFurnitureSelector() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        color: Colors.black.withOpacity(0.4),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: furnitureItems.length,
          itemBuilder: (context, index) {
            final item = furnitureItems[index];
            final isSelected = _selectedModelPath == item.modelPath;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedModelPath = item.modelPath;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(color: Colors.deepPurple, width: 3) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Make sure you have thumbnail images in your assets!
                    // Image.asset(item.thumbnail, height: 60, width: 60), 
                    Icon(Icons.chair, size: 60, color: isSelected ? Colors.deepPurple : Colors.grey),
                    const SizedBox(height: 4),
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}