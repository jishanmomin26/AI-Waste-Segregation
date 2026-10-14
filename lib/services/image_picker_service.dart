import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Encapsulates image metadata and in-memory byte buffer for cross-platform usage.
class PickedImageData {
  final String path;
  final Uint8List bytes;
  final String name;

  const PickedImageData({
    required this.path,
    required this.bytes,
    required this.name,
  });
}

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the device gallery and loads its bytes into memory.
  Future<PickedImageData?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) {
      return null;
    }

    final Uint8List bytes = await image.readAsBytes();

    return PickedImageData(path: image.path, bytes: bytes, name: image.name);
  }

  /// Captures a photo using the camera and loads its bytes into memory.
  Future<PickedImageData?> capturePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) {
      return null;
    }

    final Uint8List bytes = await image.readAsBytes();

    return PickedImageData(path: image.path, bytes: bytes, name: image.name);
  }

  /// Legacy helper returning image path for backwards compatibility.
  Future<String?> pickFromGallery() async {
    final data = await pickImageFromGallery();
    return data?.path;
  }

  /// Legacy helper returning photo path for backwards compatibility.
  Future<String?> takePhoto() async {
    final data = await capturePhoto();
    return data?.path;
  }
}
