// lib/customer_home_screen.dart

import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth_service.dart';
import 'constants/app_constants.dart';
import 'ai_assistant_screen.dart';

class Furniture {
  final String name;
  final String thumbnail;
  final String modelPath;

  Furniture({required this.name, required this.thumbnail, required this.modelPath});
}

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late ArCoreController arCoreController;
  String? _selectedModelPath;

  final List<Furniture> furnitureItems = [
    Furniture(name: 'Chair', thumbnail: 'assets/thumbnails/chair.png', modelPath: 'assets/models/chair.sfb'),
    Furniture(name: 'Sofa', thumbnail: 'assets/thumbnails/sofa.png', modelPath: 'assets/models/sofa.sfb'),
    Furniture(name: 'Table', thumbnail: 'assets/thumbnails/table.png', modelPath: 'assets/models/table.sfb'),
  ];

  @override
  void initState() {
    super.initState();
    if (furnitureItems.isNotEmpty) {
      _selectedModelPath = furnitureItems.first.modelPath;
    }
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onPlaneTap = _handleOnPlaneTap;
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    if (_selectedModelPath == null) return;
    final hit = hits.first;
    _addModel(hit);
  }

  void _addModel(ArCoreHitTestResult hit) {
    final node = ArCoreReferenceNode(
      name: _selectedModelPath!.split('/').last,
      object3DFileName: _selectedModelPath,
      position: hit.pose.translation,
      rotation: hit.pose.rotation,
    );
    arCoreController.addArCoreNodeWithAnchor(node);
  }

  Future<void> _launchCheckout() async {
    if (!mounted) return;
    final Uri url = Uri.parse('https://mandauefoam.ph/');
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch website')),
      );
    }
  }

  void _logout() async {
    await AuthService().signOut();
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
                MaterialPageRoute(builder: (context) => const AiAssistantScreen()),
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
          ArCoreView(
            onArCoreViewCreated: _onArCoreViewCreated,
            enableTapRecognizer: true,
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
                    onTap: () => setState(() => _selectedModelPath = item.modelPath),
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(item.thumbnail, height: 60),
                          const SizedBox(height: 8),
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
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