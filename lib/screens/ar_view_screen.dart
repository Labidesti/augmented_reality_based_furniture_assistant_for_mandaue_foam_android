import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ArViewScreen extends StatefulWidget {
  const ArViewScreen({super.key});

  @override
  State<ArViewScreen> createState() => _ArViewScreenState();
}

class _ArViewScreenState extends State<ArViewScreen> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AR Furniture Viewer")),
      body: ARView(
        onARViewCreated: onARViewCreated,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "sofa",
            onPressed: () => _addObject("assets/models/Sofa-Random-Example.glb"),
            child: const Icon(Icons.weekend), // Sofa icon
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "desk",
            onPressed: () => _addObject("assets/models/Coral-Desk1.glb"),
            child: const Icon(Icons.table_bar), // Desk icon
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "dining",
            onPressed: () => _addObject("assets/models/Bradmor-4-Seater-Dining-Set.glb"),
            child: const Icon(Icons.chair_alt), // Dining set icon
          ),
        ],
      ),
    );
  }

  /// Setup AR session + object manager
  void onARViewCreated(
      ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ARAnchorManager anchorManager,
      ARLocationManager locationManager,
      ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: "triangle.png",
      showWorldOrigin: true,
    );

    arObjectManager.onInitialize();
  }

  /// Add a local GLB object
  Future<void> _addObject(String path) async {
    final newNode = ARNode(
      type: NodeType.localGLTF2,
      uri: path,
      scale: vector.Vector3(0.5, 0.5, 0.5), // adjust size
      position: vector.Vector3(0.0, 0.0, -1.0), // 1m in front of camera
    );
    await arObjectManager.addNode(newNode);
  }
}