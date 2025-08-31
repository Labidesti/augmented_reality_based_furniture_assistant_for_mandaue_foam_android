import 'package:augmented_reality_based_furniture_assistant_for_mandaue_foam_android/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math.dart' as vector;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ArCoreController arCoreController;
  final String _selectedFurniture = 'assets/chair.sfb';
  List<Map<String, dynamic>> furnitureModels = [
    {'name': 'Chair', 'model': 'assets/chair.sfb'},
    {'name': 'Table', 'model': 'assets/table.sfb'},
    {'name': 'Sofa', 'model': 'assets/sofa.sfb'},
  ];

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onPlaneTap = _handleOnPlaneTap;
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    final hit = hits.first;
    _addSphere(hit);
  }

  void _addSphere(ArCoreHitTestResult hit) {
    if (_selectedFurniture.isNotEmpty) {
      final node = ArCoreReferenceNode(
        name: 'model',
        objectUrl: _selectedFurniture,
        position: hit.pose.translation,
        rotation: hit.pose.rotation,
      );
      arCoreController.addArCoreNodeWithAnchor(node);
    }
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }

  void _logout(BuildContext context) async {
    await AuthService().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AR Furniture Assistant"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enableTapRecognizer: true,
      ),
    );
  }
}
