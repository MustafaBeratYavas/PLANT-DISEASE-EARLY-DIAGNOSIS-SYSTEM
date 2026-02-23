import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();
  late String _documentsDirectoryPath;

  // Initialize storage path
  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    _documentsDirectoryPath = directory.path;
  }

  // Pick image from source
  Future<File?> pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source);
    if (picked == null) return null;
    return File(picked.path);
  }

  // Save to permanent storage
  Future<String> saveToPermanentStorage(File tempImage) async {
    final fileName = path.basename(tempImage.path);
    final savedImage = await tempImage.copy('$_documentsDirectoryPath/$fileName');
    return path.basename(savedImage.path);
  }

  // Load from storage
  File getFileFromStorage(String fileNameOrPath) {
    if (path.isAbsolute(fileNameOrPath)) {
      final fileName = path.basename(fileNameOrPath);
      return File('$_documentsDirectoryPath/$fileName');
    }
    return File('$_documentsDirectoryPath/$fileNameOrPath');
  }
}