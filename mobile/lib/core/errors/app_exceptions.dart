// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? details;
  
  const AppException(this.message, [this.details]);
  
  @override
  String toString() => details != null ? '$message: $details' : message;
}

// Network related errors
class NetworkException extends AppException {
  const NetworkException([String? details]) : super('Network error', details);
}

class TimeoutException extends AppException {
  const TimeoutException([String? details]) : super('Request timeout', details);
}

class ServerException extends AppException {
  const ServerException([String? details]) : super('Server error', details);
}

// Storage related errors
class StorageException extends AppException {
  const StorageException([String? details]) : super('Storage error', details);
}

class FileNotFoundException extends AppException {
  const FileNotFoundException([String? details]) : super('File not found', details);
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException([String? details]) : super('Permission denied', details);
}

// Model related errors
class ModelException extends AppException {
  const ModelException([String? details]) : super('Model error', details);
}

class ModelLoadException extends AppException {
  const ModelLoadException([String? details]) : super('Model load failed', details);
}

class InferenceException extends AppException {
  const InferenceException([String? details]) : super('Inference failed', details);
}

// Image related errors
class ImageException extends AppException {
  const ImageException([String? details]) : super('Image error', details);
}

class ImageProcessingException extends AppException {
  const ImageProcessingException([String? details]) : super('Processing failed', details);
}

// Permission errors
class CameraPermissionException extends AppException {
  const CameraPermissionException([String? details]) : super('Camera denied', details);
}

class GalleryPermissionException extends AppException {
  const GalleryPermissionException([String? details]) : super('Gallery denied', details);
}

// Configuration errors
class ConfigurationException extends AppException {
  const ConfigurationException([String? details]) : super('Config error', details);
}
