import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ AR plugin imports
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';

// ✅ Utilities
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:url_launcher/url_launcher.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

// ✅ Your app files
import 'auth_service.dart';
import 'constants/app_constants.dart';
import 'ai_assistant_screen.dart';



class Furniture {
  final String name;
  final String thumbnail;
  final String modelPath;

  const Furniture({
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
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  String? selectedModelPath;
  bool isArSupported = false;
  bool checkedSupport = false;
  bool dontShowDialog = false;

  final List<Furniture> furnitureItems = const [
    Furniture(
      name: 'Chair',
      thumbnail: 'assets/ar_models/thumbnails/chair.png',
      modelPath: 'assets/ar_models/chair.glb',
    ),
    Furniture(
      name: 'Sofa',
      thumbnail: 'assets/ar_models/thumbnails/sofa.png',
      modelPath: 'assets/ar_models/sofa.glb',
    ),
    Furniture(
      name: 'Table',
      thumbnail: 'assets/ar_models/thumbnails/table.png',
      modelPath: 'assets/ar_models/table.glb',
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (furnitureItems.isNotEmpty) {
      selectedModelPath = furnitureItems.first.modelPath;
    }
    _checkArSupport();
  }

  @override
  void dispose() {
    arSessionManager?.dispose();
    super.dispose();
  }

  Future<void> _checkArSupport() async {
    final prefs = await SharedPreferences.getInstance();
    dontShowDialog = prefs.getBool("skipArWarning") ?? false;

    bool supported = Platform.isAndroid || Platform.isIOS;

    if (!mounted) return;
    setState(() {
      isArSupported = supported;
      checkedSupport = true;
    });

    if (!supported && !dontShowDialog) {
      _showNoArDialog();
    }
  }




  void _showNoArDialog() {
    bool skipNextTime = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("AR Not Supported"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Your device does not support ARCore/ARKit.\n"
                      "You can still preview furniture in 3D mode.",
                ),
                Row(
                  children: [
                    Checkbox(
                      value: skipNextTime,
                      onChanged: (val) {
                        setState(() => skipNextTime = val ?? false);
                      },
                    ),
                    const Expanded(child: Text("Don’t show again")),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (skipNextTime) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool("skipArWarning", true);
                  }
                  if (mounted) Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ✅ AR setup
  Future<void> onARViewCreated(
      ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ARAnchorManager anchorManager,
      ARLocationManager locationManager,
      ) async {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    await arSessionManager?.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: true,
    );

    await arObjectManager?.onInitialize();
  }

  List<ARNode> addedNodes = [];

  Future<void> addModel() async {
    if (selectedModelPath == null || arObjectManager == null) return;

    // remove previously added nodes
    for (final node in addedNodes) {
      await arObjectManager!.removeNode(node);
    }
    addedNodes.clear();

    final node = ARNode(
      type: NodeType.localGLTF2,
      uri: selectedModelPath!,
      scale: vm.Vector3(0.5, 0.5, 0.5),
      position: vm.Vector3(0.0, 0.0, -1.0),
    );

    final didAdd = await arObjectManager!.addNode(node);
    if (didAdd == true) {
      addedNodes.add(node);
    }

  }


  /// ✅ Checkout link
  Future<void> launchCheckout() async {
    final Uri url = Uri.parse('https://mandauefoam.ph/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch website')),
      );
    }
  }

  void logout() async {
    await AuthService().signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (!checkedSupport) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
            onPressed: logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          isArSupported
              ? ARView(onARViewCreated: onARViewCreated)
              : (selectedModelPath == null)
              ? const Center(child: Text("Select a furniture to preview"))
              : ModelViewer(
            src: selectedModelPath!,
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
                  final isSelected = selectedModelPath == item.modelPath;
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedModelPath = item.modelPath);
                      if (isArSupported) addModel();
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
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (!isArSupported)
                            const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text(
                                "3D only",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                ),
                              ),
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
        onPressed: launchCheckout,
        label: const Text('Checkout'),
        icon: const Icon(Icons.shopping_cart),
        backgroundColor: primaryColor,
      ),
    );
  }
}
