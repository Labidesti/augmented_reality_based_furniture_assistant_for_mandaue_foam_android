import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';

class ARViewScreen extends StatefulWidget {
  final String modelPath; // gets passed from ProductDetailScreen

  const ARViewScreen({super.key, required this.modelPath});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;

  @override
  void dispose() {
    arSessionManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AR Preview"),
        backgroundColor: Colors.black,
      ),
      body: ARView(
        onARViewCreated: (arSessionManager, arObjectManager, arAnchorManager, arLocationManager) {
          this.arSessionManager = arSessionManager;
          this.arObjectManager = arObjectManager;

          arSessionManager.onInitialize(
            showFeaturePoints: false,
            showPlanes: true,
            customPlaneTexturePath: "assets/triangle.png",
            showWorldOrigin: true,
          );
          arObjectManager.onInitialize();

          _addModel();
        },
      ),
    );
  }

  Future<void> _addModel() async {
    final node = ARNode(
      type: NodeType.localGLTF2,
      uri: widget.modelPath, // e.g. assets/ar_models/sofa1.glb
      scale: vector.Vector3(0.5, 0.5, 0.5),
      position: vector.Vector3(0.0, 0.0, -1.0),
      rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0),
    );

    bool? didAdd = await arObjectManager?.addNode(node);
    debugPrint("AR model added: $didAdd");
  }
}
