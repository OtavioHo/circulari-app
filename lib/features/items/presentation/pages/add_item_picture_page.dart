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
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        setState(() => _initError = 'Nenhuma câmera disponível neste dispositivo.');
        return;
      }
      final cam = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await cam.initialize();
      if (!mounted) {
        await cam.dispose();
        return;
      }
      setState(() => _controller = cam);
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() => _initError = e.description ?? 'Não foi possível abrir a câmera.');
    }
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
      backgroundColor: CirculariColorsTokens.greyscale800,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
      body: _initError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _initError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          : cam == null || !cam.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              fit: StackFit.expand,
              children: [
                _CameraView(controller: cam),
                const _CameraFrame(topMargin: 190, bottomMargin: 210),
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

class _CameraView extends StatelessWidget {
  final CameraController controller;

  const _CameraView({required this.controller});

  @override
  Widget build(BuildContext context) {
    // previewSize is reported in landscape orientation; swap for portrait so
    // the preview keeps its native aspect ratio while filling the screen.
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return CameraPreview(controller);

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _CameraFrame extends StatelessWidget {
  final double topMargin;
  final double bottomMargin;

  const _CameraFrame({required this.topMargin, required this.bottomMargin});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FramePainter(topMargin: topMargin, bottomMargin: bottomMargin),
      child: const SizedBox.expand(),
    );
  }
}

class _FramePainter extends CustomPainter {
  final double topMargin;
  final double bottomMargin;

  _FramePainter({required this.topMargin, required this.bottomMargin});

  @override
  void paint(Canvas canvas, Size size) {
    const cornerRadius = 24.0;
    const horizontalPadding = 40.0;
    const cornerLength = 44.0;
    const strokeWidth = 4.0;

    final cutoutWidth = size.width - horizontalPadding * 2;
    final cutoutHeight = size.height - topMargin - bottomMargin;
    final rect = Rect.fromLTWH(
      horizontalPadding,
      topMargin,
      cutoutWidth,
      cutoutHeight,
    );
    final cutoutRect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(cornerRadius),
    );

    // Dim the area outside the cutout.
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(cutoutRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    // Rounded corner brackets.
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final left = rect.left;
    final top = rect.top;
    final right = rect.right;
    final bottom = rect.bottom;

    final cornersPath = Path()
      // Top-left
      ..moveTo(left, top + cornerLength)
      ..lineTo(left, top + cornerRadius)
      ..arcToPoint(
        Offset(left + cornerRadius, top),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(left + cornerLength, top)
      // Top-right
      ..moveTo(right - cornerLength, top)
      ..lineTo(right - cornerRadius, top)
      ..arcToPoint(
        Offset(right, top + cornerRadius),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(right, top + cornerLength)
      // Bottom-right
      ..moveTo(right, bottom - cornerLength)
      ..lineTo(right, bottom - cornerRadius)
      ..arcToPoint(
        Offset(right - cornerRadius, bottom),
        radius: const Radius.circular(cornerRadius),
        clockwise: true,
      )
      ..lineTo(right - cornerLength, bottom)
      // Bottom-left
      ..moveTo(left + cornerLength, bottom)
      ..lineTo(left + cornerRadius, bottom)
      ..arcToPoint(
        Offset(left, bottom - cornerRadius),
        radius: const Radius.circular(cornerRadius),
        clockwise: true,
      )
      ..lineTo(left, bottom - cornerLength);
    canvas.drawPath(cornersPath, cornerPaint);

    // Horizontal scan line.
    final scanY = rect.center.dy;
    canvas.drawLine(
      Offset(left, scanY),
      Offset(right, scanY),
      Paint()
        ..color = CirculariColorsTokens.solarPulse500
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _FramePainter oldDelegate) =>
      oldDelegate.topMargin != topMargin ||
      oldDelegate.bottomMargin != bottomMargin;
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
    final typography = context.circulariTheme.typography;

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
          const SizedBox(height: 24),
          Text(
            'Seguir com esta foto?',
            style: typography.body.large.semibold.copyWith(
              color: CirculariColorsTokens.greyscale50,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CirculariButton(label: 'Usar esta foto', onPressed: onUse),
          const SizedBox(height: 16),
          CirculariOutlinedButton(
            label: 'Tirar outra foto',
            onPressed: onRetake,
          ),
        ],
      ),
    );
  }
}
