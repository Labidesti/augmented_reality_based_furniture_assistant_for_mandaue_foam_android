// lib/customer_home_screen.dart
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:url_launcher/url_launcher.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import 'auth_service.dart';
import 'constants/app_constants.dart';
import 'ai_assistant_screen.dart';
import 'tutorial_no_ar_page.dart';

class Furniture {
  final String name;
  final String thumbnail;
  final String modelPath;

  Furniture({
    required this.name,
    required this.thumbnail,
    required this.modelPath,
  });
}

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  String? _selectedModelPath;
  final bool _isArSupported = true; // ar_flutter_plugin doesn’t expose ARCore checks

  final List<Furniture> furnitureItems = [
    Furniture(
      name: 'Chair',
      thumbnail: 'assets/thumbnails/chair.png',
      modelPath: 'assets/models/chair.glb',
    ),
    Furniture(
      name: 'Sofa',
      thumbnail: 'assets/thumbnails/sofa.png',
      modelPath: 'assets/models/sofa.glb',
    ),
    Furniture(
      name: 'Table',
      thumbnail: 'assets/thumbnails/table.png',
      modelPath: 'assets/models/table.glb',
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (furnitureItems.isNotEmpty) {
      _selectedModelPath = furnitureItems.first.modelPath;
    }
  }

  Future<void> _onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager,
      ) async {
    _arSessionManager = arSessionManager;
    _arObjectManager = arObjectManager;

    // ✅ Correct initialization for new ar_flutter_plugin versions
    await _arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: true,
    );

    await _arObjectManager!.onInitialize();
  }


  Future<void> _addModel() async {
    if (_selectedModelPath == null || _arObjectManager == null) return;

    final node = ARNode(
      type: NodeType.localGLTF2,
      uri: _selectedModelPath!,
      scale: vm.Vector3(0.5, 0.5, 0.5),
      position: vm.Vector3(0.0, 0.0, -1.0),
    );

    await _arObjectManager!.addNode(node);
  }

  Future<void> _launchCheckout() async {
    final Uri url = Uri.parse('https://mandauefoam.ph/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch website')),
      );
    }
  }

  void _logout() async {
    await AuthService().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AR Furniture Assistant"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            tooltip: 'AI Assistant',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AiAssistantScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          _isArSupported
              ? ARView(onARViewCreated: _onARViewCreated)
              : (_selectedModelPath == null)
              ? const Center(child: Text("Select a furniture to preview"))
              : ModelViewer(
            src: _selectedModelPath!,
            alt: "3D Furniture model",
            autoRotate: true,
            cameraControls: true,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black54,
              height: 140,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                scrollDirection: Axis.horizontal,
                itemCount: furnitureItems.length,
                itemBuilder: (context, index) {
                  final item = furnitureItems[index];
                  final isSelected = _selectedModelPath == item.modelPath;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedModelPath = item.modelPath);
                      _addModel();
                    },
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(item.thumbnail, height: 60),
                          const SizedBox(height: 8),
                          Text(
                            item.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          if (!_isArSupported)
                            const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text("3D only",
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.red)),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _launchCheckout,
        label: const Text('Checkout'),
        icon: const Icon(Icons.shopping_cart),
        backgroundColor: primaryColor,
      ),
    );
  }
}