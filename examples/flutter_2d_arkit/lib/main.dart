import 'dart:convert';

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2d_arkit/bloc/unity_bloc.dart';
import 'package:flutter_2d_arkit/components/avatar_button.dart';
import 'package:flutter_2d_arkit/model/unity_message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UnityBloc(),
      child: const FaceDetection(title: 'MYTY Example'),
    );
  }
}

class FaceDetection extends StatefulWidget {
  const FaceDetection({super.key, required this.title});

  final String title;

  @override
  State<FaceDetection> createState() => _FaceDetectionState();
}

class _FaceDetectionState extends State<FaceDetection> {
  late ARKitController arKitController;
  bool _isARMode = false;
  List<String> _loadedAvatarIds = [];

  ARKitNode? node;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Stack(
          children: [
            ARKitSceneView(
              configuration: ARKitConfiguration.faceTracking,
              onARKitViewCreated: onARKitViewCreated,
            ),
            UnityWidget(
              onUnityCreated: (controller) => {
                context
                    .read<UnityBloc>()
                    .add(UnityInitializedEvent(controller: controller))
              },
              onUnityMessage: (message) {
                var fromUnity = jsonDecode(message);
                var decoded = SelectAvatarMessage(
                  assetVersionId: fromUnity['assetVersionId'],
                  tokenId: fromUnity['tokenId']
                );
                setState(() {
                  _loadedAvatarIds.add(decoded.tokenId);
                });
              },
            ),
            Positioned(
              top: 20,
              right: 10,
              child: Switch(
                value: _isARMode,
                onChanged: (flag) {
                  setState(() {
                    _isARMode = !_isARMode;
                    context
                        .read<UnityBloc>()
                        .add(UnitySetARModeEvent(isARMode: _isARMode));
                  });
                },
              )
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 30,
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: _loadedAvatarIds
                      .map((e) => AvatarButton(
                            collectionAddress:
                                "0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d",
                            tokenID: e,
                          ))
                      .toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void onARKitViewCreated(ARKitController arKitController) {
    this.arKitController = arKitController;
    this.arKitController.onUpdateNodeForAnchor = _handleUpdateAnchor;
  }

  void _handleUpdateAnchor(ARKitAnchor anchor) async {
    if (anchor is ARKitFaceAnchor && mounted) {
      var upVector = anchor.transform.up;
      var forwardVector = anchor.transform.forward;
      context.read<UnityBloc>().add(UnityMotionCapturedEvent(
          arKitData: ARKitData(
              facePosition: vm.Vector3(0, 0, 0),
              faceScale: vm.Vector3(1, 1, 1),
              up: vm.Vector3(-upVector.x, upVector.y, upVector.z),
              forward: anchor.transform.forward,
              blendshapes: ARKitBlendShape(
                  browDownLeft: anchor.blendShapes['browDown_L'] ?? 0,
                  browDownRight: anchor.blendShapes['browDown_R'] ?? 0,
                  browOuterUpLeft: anchor.blendShapes['browOuterUp_L'] ?? 0,
                  browOuterUpRight: anchor.blendShapes['browOuterUp_R'] ?? 0,
                  eyeBlinkLeft: anchor.blendShapes['eyeBlink_L'] ?? 0,
                  eyeBlinkRight: anchor.blendShapes['eyeBlink_R'] ?? 0,
                  jawOpen: anchor.blendShapes['jawOpen'] ?? 0,
                  mouthClose: anchor.blendShapes['mouthClose'] ?? 0,
                  mouthPucker: anchor.blendShapes['mouthPucker'] ?? 0,
                  mouthSmileLeft: anchor.blendShapes['mouthSmile_L'] ?? 0,
                  mouthSmileRight: anchor.blendShapes['mouthSmile_R'] ?? 0,
                  mouthStretchLeft: anchor.blendShapes['mouthStretch_L'] ?? 0,
                  mouthStretchRight:
                      anchor.blendShapes['mouthStretch_R'] ?? 0))));

      // arKitController.updateFaceGeometry(node!, anchor.identifier);
      // final projectionMatrix = await arKitController.cameraProjectionMatrix();
      // final viewMatrix = await arKitController.pointOfViewTransform();
      // translation
      // viewport translation
      // ARKit samples -> apple developer
    }
  }

  vm.Vector2 projectPoint(Matrix4 modelViewProjectionMatrix, vm.Vector3 point) {
    final projectedPoint =
        modelViewProjectionMatrix * vm.Vector4(point.x, point.y, point.z, 1.0);
    final double x = (projectedPoint.x / projectedPoint.w + 1.0) / 2.0;
    final double y = 1.0 - (projectedPoint.y / projectedPoint.w + 1.0) / 2.0;
    return vm.Vector2(x, y);
  }
}