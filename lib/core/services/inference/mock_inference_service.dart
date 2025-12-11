import 'dart:math';

import 'package:serfix/core/services/inference/inference_service.dart';
import 'package:serfix/features/doctor/screening/domain/entities/screening_result.dart';

/// Mock implementation of InferenceService for testing/demo purposes.
///
/// Simulates AI inference with:
/// - Random delay (2-5 seconds) to mimic processing time
/// - Random classification results (70% normal, 20% abnormal, 10% inconclusive)
/// - Random confidence scores
/// - Mock detection boxes for abnormal results
class MockInferenceService implements InferenceService {
  final Random _random = Random();

  @override
  Future<InferenceResult> runInference({
    required String screeningId,
    required String imageUrl,
  }) async {
    // Simulate processing delay (2-5 seconds)
    final processingTime = 2000 + _random.nextInt(3000);
    await Future.delayed(Duration(milliseconds: processingTime));

    // Generate random classification
    // 70% normal, 20% abnormal, 10% inconclusive
    final roll = _random.nextDouble();
    Classification classification;
    double confidence;
    List<DetectionResult>? detections;

    if (roll < 0.70) {
      // Normal
      classification = Classification.normal;
      confidence = 0.85 + _random.nextDouble() * 0.14; // 0.85 - 0.99
      detections = null;
    } else if (roll < 0.90) {
      // Abnormal
      classification = Classification.abnormal;
      confidence = 0.75 + _random.nextDouble() * 0.20; // 0.75 - 0.95
      detections = _generateMockDetections();
    } else {
      // Inconclusive
      classification = Classification.inconclusive;
      confidence = 0.45 + _random.nextDouble() * 0.25; // 0.45 - 0.70
      detections = null;
    }

    return InferenceResult(
      classification: classification,
      confidence: confidence,
      detections: detections,
      resultImageUrl: null, // Mock doesn't generate annotated images
      modelVersion: 'mock-v1.0.0',
      inferenceTimeMs: processingTime,
    );
  }

  /// Generate mock detection boxes for abnormal results
  List<DetectionResult> _generateMockDetections() {
    final count = 1 + _random.nextInt(3); // 1-3 detections
    final detections = <DetectionResult>[];

    final labels = ['lesion', 'abnormal_cells', 'suspicious_area'];
    final severities = ['low', 'medium', 'high'];

    for (int i = 0; i < count; i++) {
      detections.add(DetectionResult(
        label: labels[_random.nextInt(labels.length)],
        confidence: 0.60 + _random.nextDouble() * 0.35, // 0.60 - 0.95
        bbox: [
          50 + _random.nextInt(200), // x
          50 + _random.nextInt(200), // y
          30 + _random.nextInt(100), // width
          30 + _random.nextInt(100), // height
        ],
        severity: severities[_random.nextInt(severities.length)],
      ));
    }

    return detections;
  }
}
