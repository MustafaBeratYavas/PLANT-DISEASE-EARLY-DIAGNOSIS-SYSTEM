import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/errors/app_exceptions.dart';
import 'package:mobile/core/errors/error_handler.dart';

void main() {
  group('AppExceptions', () {
    test('AppException creates with message', () {
      const exception = AppException(message: 'Test error');
      expect(exception.message, 'Test error');
      expect(exception.code, isNull);
    });

    test('NetworkException has correct defaults', () {
      const exception = NetworkException();
      expect(exception.code, 'NETWORK_ERROR');
      expect(exception.message, 'Network error occurred');
    });

    test('StorageException includes file path', () {
      const exception = StorageException(
        message: 'File not found',
        filePath: '/path/to/file',
      );
      expect(exception.filePath, '/path/to/file');
    });

    test('ModelException has correct code', () {
      const exception = ModelException(message: 'Model load failed');
      expect(exception.code, 'MODEL_ERROR');
    });

    test('PermissionException includes permission name', () {
      const exception = PermissionException(permission: 'camera');
      expect(exception.permission, 'camera');
    });
  });

  group('ErrorHandler', () {
    test('getUserMessage returns network message for NetworkException', () {
      const exception = NetworkException();
      final message = ErrorHandler.getUserMessage(exception);
      expect(message, contains('bağlantı'));
    });

    test('getUserMessage returns storage message for StorageException', () {
      const exception = StorageException();
      final message = ErrorHandler.getUserMessage(exception);
      expect(message, contains('Depolama'));
    });

    test('getUserMessage returns fallback for unknown error', () {
      final message = ErrorHandler.getUserMessage(
        Exception('Unknown'),
        fallback: 'Custom fallback',
      );
      expect(message, 'Custom fallback');
    });

    test('isRecoverable returns true for network errors', () {
      const exception = NetworkException();
      expect(ErrorHandler.isRecoverable(exception), isTrue);
    });

    test('isRecoverable returns true for permission errors', () {
      const exception = PermissionException();
      expect(ErrorHandler.isRecoverable(exception), isTrue);
    });

    test('isRecoverable returns false for model errors', () {
      const exception = ModelException();
      expect(ErrorHandler.isRecoverable(exception), isFalse);
    });
  });
}
