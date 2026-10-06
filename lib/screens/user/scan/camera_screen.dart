import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_routes.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  bool _isInitializing = true;
  bool _isTakingPicture = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (mounted) {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });
    }

    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        throw Exception('No camera available.');
      }

      CameraDescription selectedCamera = _cameras.first;

      for (final camera in _cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          selectedCamera = camera;
          break;
        }
      }

      final previousController = _controller;
      _controller = null;
      await previousController?.dispose();

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _controller = controller;

      await controller.initialize();

      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
      });
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _errorMessage = _cameraErrorMessage(error);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _errorMessage = 'Unable to access the camera. Please try again.';
      });
    }
  }

  String _cameraErrorMessage(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
        return 'Camera permission was denied. Please allow camera access.';
      case 'CameraAccessDeniedWithoutPrompt':
        return 'Camera access is disabled. Please enable it in device settings.';
      case 'CameraAccessRestricted':
        return 'Camera access is restricted on this device.';
      default:
        return 'Unable to access the camera. Please try again.';
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;

    if (_isTakingPicture ||
        controller == null ||
        !controller.value.isInitialized) {
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      final XFile image = await controller.takePicture();

      if (!mounted) {
        return;
      }

      Navigator.pushNamed(
        context,
        AppRoutes.imagePreview,
        arguments: image.path,
      );
    } on CameraException {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to capture photo. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  void _switchCamera() {
    if (_cameras.length < 2 || _controller == null || _isTakingPicture) {
      return;
    }

    final currentLens = _controller!.description.lensDirection;

    CameraDescription? nextCamera;

    for (final camera in _cameras) {
      if (camera.lensDirection != currentLens) {
        nextCamera = camera;
        break;
      }
    }

    if (nextCamera == null) {
      return;
    }

    _changeCamera(nextCamera);
  }

  Future<void> _changeCamera(CameraDescription camera) async {
    setState(() {
      _isInitializing = true;
    });

    final oldController = _controller;
    _controller = null;

    await oldController?.dispose();

    try {
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _controller = controller;

      await controller.initialize();

      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
      });
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _errorMessage = _cameraErrorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    final cameraReady =
        controller != null &&
        controller.value.isInitialized &&
        !_isInitializing;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child:
                  cameraReady
                      ? _buildCameraPreview(controller)
                      : _buildCameraState(),
            ),

            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopButton(
                    icon: Icons.close_rounded,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildTopButton(
                    icon: Icons.flip_camera_ios_outlined,
                    onPressed: _cameras.length > 1 ? _switchCamera : null,
                  ),
                ],
              ),
            ),

            if (cameraReady)
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: _buildCameraControls(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(CameraController controller) {
    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }

  Widget _buildCameraState() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Camera Unavailable',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: _initializeCamera,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildTopButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: onPressed == null ? Colors.white38 : Colors.white,
        ),
        tooltip: icon == Icons.close_rounded ? 'Close' : 'Switch camera',
      ),
    );
  }

  Widget _buildCameraControls() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Position the waste item inside the frame',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 22),

        GestureDetector(
          onTap: _isTakingPicture ? null : _capturePhoto,
          child: Container(
            width: 78,
            height: 78,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: _isTakingPicture ? Colors.white54 : Colors.white,
                shape: BoxShape.circle,
              ),
              child:
                  _isTakingPicture
                      ? const Padding(
                        padding: EdgeInsets.all(22),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : null,
            ),
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          'Tap to capture',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
