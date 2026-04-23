import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  CameraController? controller;
  XFile? image;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final cam = CameraController(cameras.first, ResolutionPreset.high);
    await cam.initialize();
    if (mounted) {
      setState(() => controller = cam);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final cam = controller;
    final buildImage = image;

    if (cam == null || !cam.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Item')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Column(
        children: [
          ClipOval(
            clipper: CircleClipper(),
            child: buildImage != null
                ? Image.file(File(buildImage.path))
                : CameraPreview(cam),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final capturedImage = await cam.takePicture();
                setState(() {
                  image = capturedImage;
                });
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Error capturing image: $e')),
                );
              }
            },
            child: const Text('Capture Image'),
          ),
        ],
      ),
    );
  }
}

class CircleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    return Rect.fromCircle(center: center, radius: radius);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
