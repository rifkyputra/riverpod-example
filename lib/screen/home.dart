import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryriverpod/providers/app_setup/app_setup_provider.dart';
import 'package:tryriverpod/screen/complete_profile.dart';
import 'package:tryriverpod/screen/counter.dart';
import 'package:tryriverpod/screen/form.dart';
import 'package:tryriverpod/screen/login.dart';

import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/widgets/ar_view.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Consumer(builder: (context, ref, __) {
              String? name;

              ref.watch(appSetupProvider).whenData((value) {
                if (value.user != null && value.user!.email != null) {
                  name = value.user!.email!;
                }
              });

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Text('Hello, ${name ?? "Guest"}'),
                    if (name != null)
                      TextButton(
                        child: Text('Sign Out'),
                        onPressed: () {
                          ref.read(appSetupServiceProvider).signOut();
                        },
                      )
                  ],
                ),
              );
            }),
          ),
          Expanded(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Home'),
                  CounterScreen(),
                  SizedBox(height: 12),
                  GoToForm(),
                  SizedBox(height: 12),
                  GoToComProf(),
                  SizedBox(height: 12),
                  GoToSignIn(),
                  SizedBox(height: 12),
                  GotToAR(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GoToForm extends StatelessWidget {
  const GoToForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FormPage()),
      ),
      child: const Text('Go To Dynamic Form'),
    );
  }
}

class GoToComProf extends StatelessWidget {
  const GoToComProf({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
      ),
      child: const Text('Go To Complete Profile'),
    );
  }
}

class GoToSignIn extends StatelessWidget {
  const GoToSignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        ),
        child: const Text('Sign In'),
      ),
    );
  }
}

class GotToAR extends StatelessWidget {
  const GotToAR({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ObjectsOnPlanesWidget()),
        ),
        child: const Text('Open AR'),
      ),
    );
  }
}

class ObjectsOnPlanesWidget extends StatefulWidget {
  ObjectsOnPlanesWidget({Key? key}) : super(key: key);
  @override
  _ObjectsOnPlanesWidgetState createState() => _ObjectsOnPlanesWidgetState();
}

class _ObjectsOnPlanesWidgetState extends State<ObjectsOnPlanesWidget> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;

  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];

  @override
  void dispose() {
    super.dispose();
    arSessionManager.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Anchors & Objects on Planes'),
        ),
        body: Container(
            child: Stack(children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: onRemoveEverything,
                      child: Text("Remove Everything")),
                ]),
          )
        ])));
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager.onInitialize(
          showFeaturePoints: true,
          showPlanes: false,
          customPlaneTexturePath: "Images/triangle.png",
          showWorldOrigin: false,
          showAnimatedGuide: true,
        );

    this.arSessionManager.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arObjectManager.onNodeTap = onNodeTapped;
  }

  Future<void> onRemoveEverything() async {
    /*nodes.forEach((node) {
      this.arObjectManager.removeNode(node);
    });*/
    for (var anchor in anchors) {
      arAnchorManager.removeAnchor(anchor);
    }
    anchors = [];
  }

  Future<void> onNodeTapped(List<String> nodes) async {
    var number = nodes.length;
    arSessionManager.onError("Tapped $number node(s)");
  }

  Future<void> onPlaneOrPointTapped(
      List<ARHitTestResult> hitTestResults) async {
    if (hitTestResults.isEmpty) return;
    var singleHitTestResult = hitTestResults.firstWhere(
        (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    if (singleHitTestResult != null) {
      var newAnchor =
          ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
      bool? didAddAnchor = await arAnchorManager.addAnchor(newAnchor);
      if (didAddAnchor ?? false) {
        anchors.add(newAnchor);
        // Add note to anchor
        var newNode = ARNode(
            type: NodeType.webGLB,
            uri:
                "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/AlphaBlendModeTest/glTF-Binary/AlphaBlendModeTest.glb",
            scale: Vector3(0.2, 0.2, 0.2),
            position: Vector3(0.0, 0.0, 0.0),
            rotation: Vector4(1.0, 0.0, 0.0, 0.0));
        bool? didAddNodeToAnchor =
            await arObjectManager.addNode(newNode, planeAnchor: newAnchor);
        if (didAddNodeToAnchor ?? false) {
          nodes.add(newNode);
        } else {
          arSessionManager.onError("Adding Node to Anchor failed");
        }
      } else {
        arSessionManager.onError("Adding Anchor failed");
      }
      /*
      // To add a node to the tapped position without creating an anchor, use the following code (Please mind: the function onRemoveEverything has to be adapted accordingly!):
      var newNode = ARNode(
          type: NodeType.localGLTF2,
          uri: "Models/Chicken_01/Chicken_01.gltf",
          scale: Vector3(0.2, 0.2, 0.2),
          transformation: singleHitTestResult.worldTransform);
      bool didAddWebNode = await this.arObjectManager.addNode(newNode);
      if (didAddWebNode) {
        this.nodes.add(newNode);
      }*/
    }
  }
}
