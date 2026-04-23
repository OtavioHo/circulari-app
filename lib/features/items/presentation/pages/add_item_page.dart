import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddItemPage extends StatefulWidget {
  final String listId;

  const AddItemPage({super.key, required this.listId});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  CameraController? _controller;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final cam = CameraController(cameras.first, ResolutionPreset.high);
    await cam.initialize();
    if (mounted) {
      setState(() => _controller = cam);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final cam = _controller;
    if (cam == null || !cam.value.isInitialized || _isCapturing) return;

    setState(() => _isCapturing = true);
    try {
      final file = await cam.takePicture();
      if (!mounted) return;
      await _showConfirmation(file.path);
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _showConfirmation(String imagePath) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _PhotoConfirmationSheet(
        imagePath: imagePath,
        onUse: () {
          Navigator.of(ctx).pop();
          context.push(
            '/items/add/form',
            extra: {'listId': widget.listId, 'imagePath': imagePath},
          );
        },
        onRetake: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cam = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Take a photo'),
      ),
      body: cam == null || !cam.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(cam),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _isCapturing ? null : _capture,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isCapturing
                                  ? Colors.white54
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _PhotoConfirmationSheet extends StatelessWidget {
  final String imagePath;
  final VoidCallback onUse;
  final VoidCallback onRetake;

  const _PhotoConfirmationSheet({
    required this.imagePath,
    required this.onUse,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(imagePath),
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Use this photo?',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onUse,
            child: const Text('Use photo'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onRetake,
            child: const Text('Retake'),
          ),
        ],
      ),
    );
  }
}
