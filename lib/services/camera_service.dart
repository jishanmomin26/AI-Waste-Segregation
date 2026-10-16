import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraService._internal();

  static final CameraService instance = CameraService._internal();

  List<CameraDescription> _availableCameras = [];

  List<CameraDescription> get availableDeviceCameras => _availableCameras;

  /// Fetches available cameras on the device.
  Future<List<CameraDescription>> getCameras() async {
    try {
      _availableCameras = await availableCameras();
      return _availableCameras;
    } catch (e) {
      debugPrint('Error getting cameras: $e');
      return [];
    }
  }

  /// Returns the preferred back camera, or first available camera.
  CameraDescription? getPreferredCamera() {
    if (_availableCameras.isEmpty) return null;

    for (final cam in _availableCameras) {
      if (cam.lensDirection == CameraLensDirection.back) {
        return cam;
      }
    }
    return _availableCameras.first;
  }
}

