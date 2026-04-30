import 'dart:io';

import 'package:camera/camera.dart';
import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:circulari/features/items/presentation/pages/add_item_form_args.dart';
import 'package:circulari/features/lists/domain/entities/item_list.dart';

class AddItemPicturePage extends StatefulWidget {
  final String listId;
  final ItemList? list;

  const AddItemPicturePage({super.key, required this.listId, this.list});

  @override
  State<AddItemPicturePage> createState() => _AddItemPicturePageState();
}

class _AddItemPicturePageState extends State<AddItemPicturePage> {
  CameraController? _controller;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (!mounted) return;
    final cam = CameraController(cameras.first, ResolutionPreset.high);
    await cam.initialize();
    if (!mounted) {
      await cam.dispose();
      return;
    }
    setState(() => _controller = cam);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    await _showConfirmation(file.path);
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
            extra: AddItemFormArgs(
              listId: widget.listId,
              imagePath: imagePath,
              list: widget.list,
            ),
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
      body: cam == null || !cam.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(cam),
                const _CameraFrame(),
                Positioned(
                  top: 16,
                  right: 16,
                  child: SafeArea(
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.close,
                        color: CirculariColorsTokens.greyscale50,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Escaneie o Produto',
                            textAlign: TextAlign.center,
                            style: context.circulariTheme.typography.heading3
                                .copyWith(
                                  color: CirculariColorsTokens.greyscale50,
                                ),
                          ),
                          Text(
                            'Aponte a câmera do celular para o produto que deseja adicionar.',
                            textAlign: TextAlign.center,
                            style: context
                                .circulariTheme
                                .typography
                                .body
                                .medium
                                .regular
                                .copyWith(
                                  color: CirculariColorsTokens.greyscale50,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          CirculariButton(
                            label: 'Carregar da galeria',
                            onPressed: _pickFromGallery,
                          ),
                          SizedBox(
                            height: context.circulariTheme.spacing.medium,
                          ),
                          GestureDetector(
                            onTap: _isCapturing ? null : _capture,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CameraFrame extends StatelessWidget {
  const _CameraFrame();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FramePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const radius = Radius.circular(16);
    const horizontalPadding = 40.0;
    const aspectRatio = 4 / 3;

    final cutoutWidth = size.width - horizontalPadding * 2;
    final cutoutHeight = cutoutWidth / aspectRatio;
    final cutoutTop = (size.height - cutoutHeight) / 2;
    final cutoutRect = RRect.fromLTRBR(
      horizontalPadding,
      cutoutTop,
      size.width - horizontalPadding,
      cutoutTop + cutoutHeight,
      radius,
    );

    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(cutoutRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    canvas.drawRRect(
      cutoutRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
            child: Image.file(File(imagePath), height: 300, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Text(
            'Use this photo?',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onUse, child: const Text('Use photo')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetake, child: const Text('Retake')),
        ],
      ),
    );
  }
}
