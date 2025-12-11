import 'package:serfix/features/doctor/screening/domain/entities/screening_result.dart';

/// Abstract interface for AI inference services.
///
/// This allows easy swapping between:
/// - MockInferenceService (for testing/demo)
/// - FastApiInferenceService (for production)
abstract class InferenceService {
  /// Run inference on a screening image.
  ///
  /// [screeningId] - The ID of the screening to process
  /// [imageUrl] - URL of the image to analyze
  ///
  /// Returns the inference result or throws an exception on failure.
  Future<InferenceResult> runInference({
    required String screeningId,
    required String imageUrl,
  });
}

/// Result from the inference service
class InferenceResult {
  final Classification classification;
  final double confidence;
  final List<DetectionResult>? detections;
  final String? resultImageUrl;
  final String modelVersion;
  final int inferenceTimeMs;

  InferenceResult({
    required this.classification,
    required this.confidence,
    this.detections,
    this.resultImageUrl,
    required this.modelVersion,
    required this.inferenceTimeMs,
  });
}

/// Detection result from AI model
class DetectionResult {
  final String label;
  final double confidence;
  final List<int>? bbox; // [x, y, width, height]
  final String? severity; // low, medium, high

  DetectionResult({
    required this.label,
    required this.confidence,
    this.bbox,
    this.severity,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'confidence': confidence,
        'bbox': bbox,
        'severity': severity,
      };
}
