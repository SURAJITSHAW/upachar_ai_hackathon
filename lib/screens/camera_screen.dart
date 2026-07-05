import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';
import '../theme/app_colors.dart';
import 'processing_screen.dart';

/// Live camera preview with a prescription framing overlay.
///
/// Lifecycle rules the camera plugin requires:
/// - `availableCameras()` before constructing the controller;
/// - `initialize()` awaited inside try/catch (permission denials and
///   missing hardware surface here and show the fallback screen);
/// - controller disposed on widget dispose AND on app pause, then
///   re-created on resume (Android reclaims the camera in background).
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initFuture;
  bool _permissionDenied = false;
  bool _torchOn = false;
  bool _capturing = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw CameraException('noCamera', 'No camera');
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _controller = controller;
      _initFuture = controller.initialize();
      await _initFuture;
      if (!mounted) return;
      setState(() => _permissionDenied = false);
    } on CameraException catch (e) {
      debugPrint('Camera initialization failed: $e');
      if (!mounted) return;
      setState(() => _permissionDenied = true);
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
      if (!mounted) return;
      setState(() => _permissionDenied = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.setFlashMode(_torchOn ? FlashMode.off : FlashMode.torch);
      setState(() => _torchOn = !_torchOn);
    } on CameraException catch (e) {
      debugPrint('Flash unsupported: $e');
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      _goToProcessing(file.path);
    } on CameraException catch (e) {
      debugPrint('Capture failed: $e');
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      _goToProcessing(file.path);
    } catch (e) {
      debugPrint('Gallery pick failed: $e');
    }
  }

  void _goToProcessing(String path) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ProcessingScreen(imagePath: path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;

    if (_permissionDenied) {
      return _PermissionFallback(strings: strings, onRetry: _initCamera);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Text(
                    strings.get('scanPrescription'),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  CircleAvatar(
                    backgroundColor: _torchOn
                        ? AppColors.success
                        : Colors.white24,
                    child: IconButton(
                      icon: Icon(
                        _torchOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      ),
                      onPressed: _toggleTorch,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<void>(
                future: _initFuture,
                builder: (context, snapshot) {
                  final controller = _controller;
                  if (snapshot.connectionState != ConnectionState.done ||
                      controller == null ||
                      !controller.value.isInitialized) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white54),
                    );
                  }
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(controller),
                      Center(
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Container(
                            margin: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primaryContainer,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  strings.get('alignPrescription'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BottomAction(
                    icon: Icons.photo_library_outlined,
                    label: strings.get('gallery'),
                    onTap: _pickFromGallery,
                  ),
                  GestureDetector(
                    onTap: _capture,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(
                          color: AppColors.primaryContainer,
                          width: 4,
                        ),
                      ),
                      child: _capturing
                          ? const Padding(
                              padding: EdgeInsets.all(22),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 32,
                            ),
                    ),
                  ),
                  _BottomAction(
                    icon: Icons.help_outline,
                    label: strings.get('help'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _PermissionFallback extends StatelessWidget {
  const _PermissionFallback({required this.strings, required this.onRetry});

  final dynamic strings;

  /// Re-runs camera initialization after the user returns from settings,
  /// so a freshly granted permission takes effect without leaving the screen.
  final Future<void> Function() onRetry;

  Future<void> _openSettings() async {
    await openAppSettings();
    await onRetry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.no_photography_outlined,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                strings.get('cameraPermissionTitle'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHigh,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                strings.get('cameraPermissionBody'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppColors.textLow),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _openSettings,
                child: Text(strings.get('openSettings')),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(strings.get('cancel')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
