import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/models/scan_history_model.dart';
import '../../../services/ai/classifier_service.dart';
import '../../../services/media/media_service.dart';
import '../../history/controllers/history_controller.dart';

// UI state enum
enum DiagnosisStatus { greeting, analyzing, result, error }

class DiagnosisController extends ChangeNotifier {

  // Constructor injection
  DiagnosisController(this._classifierService, this._historyController);
  final ClassifierService _classifierService;
  final HistoryController _historyController;

  DiagnosisStatus _status = DiagnosisStatus.greeting;
  Map<String, dynamic>? _topResult;
  Map<String, dynamic>? _secondResult;
  String? _customBubbleMessage;
  String? _customBubbleTitle;

  // State getters
  DiagnosisStatus get status => _status;
  Map<String, dynamic>? get topResult => _topResult;
  Map<String, dynamic>? get secondResult => _secondResult;
  String? get customBubbleMessage => _customBubbleMessage;
  String? get customBubbleTitle => _customBubbleTitle;

  // Initialize classifier model
  Future<void> initialize() async {
    await _classifierService.initialize();
  }

  // Reset to initial state
  void reset() {
    _status = DiagnosisStatus.greeting;
    _topResult = null;
    _secondResult = null;
    _customBubbleMessage = null;
    _customBubbleTitle = null;
    notifyListeners();
  }

  // Update bubble message
  void updateBubbleMessage(String message, {String? title}) {
    _customBubbleMessage = message;
    _customBubbleTitle = title;
    notifyListeners();
  }

  // Run image analysis
  Future<void> analyzeImage(File image) async {
    _status = DiagnosisStatus.analyzing;
    _customBubbleMessage = null;
    _customBubbleTitle = null;
    notifyListeners();

    try {
      // Parallel minimum wait
      final minWait = Future<void>.delayed(const Duration(seconds: 3));
      final predictionFuture = _classifierService.predict(image);

      final results = await Future.wait([minWait, predictionFuture]);
      final predictions = results[1] as List<Map<String, dynamic>>;

      if (predictions.isEmpty) {
        throw Exception('No prediction results');
      }

      // Extract top results
      _topResult = predictions.first;

      if (predictions.length > 1 && (predictions[1]['confidence'] as double) > 0.1) {
        _secondResult = predictions[1];
      } else {
        _secondResult = null;
      }

      await _saveToHistory(image, _topResult!);

      _status = DiagnosisStatus.result;
    } catch (e) {
      _status = DiagnosisStatus.error;
    }
    notifyListeners();
  }

  // Save scan to history
  Future<void> _saveToHistory(File image, Map<String, dynamic> result) async {
    final mediaService = getIt<MediaService>();
    final fileName = await mediaService.saveToPermanentStorage(image);

    // Create history entry
    final historyItem = ScanHistoryModel(
      id: const Uuid().v4(),
      imagePath: fileName,
      diseaseId: result['label'] as String,
      confidence: (result['confidence'] as num).toDouble(),
      date: DateTime.now(),
    );
    _historyController.addScan(historyItem);
  }
}