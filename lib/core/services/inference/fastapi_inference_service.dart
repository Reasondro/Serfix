import 'package:dio/dio.dart';
import 'package:serfix/core/services/inference/inference_service.dart';
import 'package:serfix/features/doctor/screening/domain/entities/screening_result.dart';

/// FastAPI implementation of InferenceService for production use.
///
/// Calls your FastAPI server endpoint to run YOLO inference on cervical images.
///
/// Expected API contract:
/// POST /inference
/// Request body: { "screening_id": "uuid", "image_url": "https://..." }
/// Response: {
///   "classification": "normal" | "abnormal" | "inconclusive",
///   "confidence": 0.95,
///   "detections": [
///     { "label": "lesion", "confidence": 0.87, "bbox": [x, y, w, h], "severity": "high" }
///   ],
///   "result_image_url": "https://...",
///   "model_version": "yolo-v8-cervical-1.0",
///   "inference_time_ms": 1234
/// }
class FastApiInferenceService implements InferenceService {
  final Dio _dio;
  final String baseUrl;

  FastApiInferenceService({
    required this.baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  @override
  Future<InferenceResult> runInference({
    required String screeningId,
    required String imageUrl,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/inference',
        data: {
          'screening_id': screeningId,
          'image_url': imageUrl,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return _parseResponse(data);
      } else {
        throw InferenceException(
          'Inference failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw InferenceException(
        'Network error during inference: ${e.message}',
      );
    } catch (e) {
      if (e is InferenceException) rethrow;
      throw InferenceException('Unexpected error: $e');
    }
  }

  InferenceResult _parseResponse(Map<String, dynamic> data) {
    // Parse classification
    final classificationStr = data['classification'] as String;
    final classification = Classification.fromString(classificationStr);

    // Parse confidence
    final confidence = (data['confidence'] as num).toDouble();

    // Parse detections if present
    List<DetectionResult>? detections;
    if (data['detections'] != null) {
      detections = (data['detections'] as List).map((d) {
        return DetectionResult(
          label: d['label'] as String,
          confidence: (d['confidence'] as num).toDouble(),
          bbox: d['bbox'] != null
              ? (d['bbox'] as List).map((e) => e as int).toList()
              : null,
          severity: d['severity'] as String?,
        );
      }).toList();
    }

    return InferenceResult(
      classification: classification,
      confidence: confidence,
      detections: detections,
      resultImageUrl: data['result_image_url'] as String?,
      modelVersion: data['model_version'] as String? ?? 'unknown',
      inferenceTimeMs: data['inference_time_ms'] as int? ?? 0,
    );
  }
}

/// Exception thrown when inference fails
class InferenceException implements Exception {
  final String message;

  InferenceException(this.message);

  @override
  String toString() => 'InferenceException: $message';
}
