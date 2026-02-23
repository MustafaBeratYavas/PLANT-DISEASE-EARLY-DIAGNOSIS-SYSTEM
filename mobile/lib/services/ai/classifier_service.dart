import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../../core/constants/app_assets.dart';

// Isolate transfer payload
class InferenceData {
  final Uint8List imageBytes;
  final Uint8List modelBytes;
  final List<String> labels;

  InferenceData({
    required this.imageBytes,
    required this.modelBytes,
    required this.labels,
  });
}

class ClassifierService {
  Uint8List? _modelBuffer;
  List<String> _labels = [];

  // Initialize model service
  Future<void> initialize() async {
    await _loadModelBytes();
    await _loadLabels();
  }

  // Load model binary
  Future<void> _loadModelBytes() async {
    final byteData = await rootBundle.load(AppAssets.model);
    _modelBuffer = byteData.buffer.asUint8List();
  }

  // Load class labels
  Future<void> _loadLabels() async {
    final labelData = await rootBundle.loadString(AppAssets.labels);
    _labels = labelData
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // Execute prediction pipeline
  Future<List<Map<String, dynamic>>> predict(File imageFile) async {
    if (_modelBuffer == null || _labels.isEmpty) {
      throw Exception('Model not initialized');
    }

    // Read image bytes
    final imageBytes = await imageFile.readAsBytes();

    // Pack isolate payload
    final inferenceData = InferenceData(
      imageBytes: imageBytes,
      modelBytes: _modelBuffer!,
      labels: _labels,
    );

    // Run in background
    return await compute(_runInferenceInIsolate, inferenceData);
  }
}

// Background inference logic
Future<List<Map<String, dynamic>>> _runInferenceInIsolate(InferenceData data) async {
  // Create interpreter instance
  final interpreter = Interpreter.fromBuffer(data.modelBytes);

  // Decode and orient image
  var rawImage = img.decodeImage(data.imageBytes)!;
  rawImage = img.bakeOrientation(rawImage);
  final resized = img.copyResize(rawImage, width: 224, height: 224);

  // Check input tensor type
  final inputType = interpreter.getInputTensor(0).type;
  final isQuantized = (inputType == TfLiteType.kTfLiteUInt8);

  // Construct input tensor
  var input = List.generate(
    1,
    (_) => List.generate(
      224,
      (y) => List.generate(
        224,
        (x) {
          final pixel = resized.getPixel(x, y);
          if (isQuantized) {
            // Quantized uint8 input
            return [
              pixel.r.toInt(),
              pixel.g.toInt(),
              pixel.b.toInt(),
            ];
          } else {
            // Float input (MobileNetV3 handles normalization internally)
            return [
              pixel.r.toDouble(),
              pixel.g.toDouble(),
              pixel.b.toDouble(),
            ];
          }
        },
      ),
    ),
  );

  // Allocate output tensor
  final outputShape = interpreter.getOutputTensor(0).shape;
  final output = List.filled(outputShape[1], 0.0).reshape([1, outputShape[1]]);

  // Execute model inference
  interpreter.run(input, output);

  // Release model resources
  interpreter.close();

  // Process output results
  final outputList = output[0] as List<double>;
  final results = <Map<String, dynamic>>[];

  for (int i = 0; i < outputList.length; i++) {
    // Map labels to scores
    if (i < data.labels.length) {
      results.add({
        'label': data.labels[i],
        'confidence': outputList[i],
      });
    }
  }

  // Sort by confidence desc
  results.sort((a, b) =>
      (b['confidence'] as double).compareTo(a['confidence'] as double));

  return results.take(5).toList();
}