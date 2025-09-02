// lib/customer_home_screen.dart

import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth_service.dart';

// A simple data class for our furniture items
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
    // This check prevents an error if the user navigates away
    if (!mounted) return;

    final Uri url = Uri.parse('https://mandauefoam.ph/'); // Mandaue Foam Website
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              // Using a direct color with opacity is more modern
              color: Colors.black54,
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: furnitureItems.length,
                itemBuilder: (context, index) {
                  final item = furnitureItems[index];
                  final isSelected = _selectedModelPath == item.modelPath;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedModelPath = item.modelPath),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected ? Border.all(color: Colors.blue, width: 3) : null,
                      ),
                      child: Center(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold))),
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
        label: const Text('Checkout on Website'),
        icon: const Icon(Icons.shopping_cart),
      ),
    );
  }
}