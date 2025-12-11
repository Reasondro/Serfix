import 'package:serfix/core/services/inference/inference_service.dart';
import 'package:serfix/features/doctor/screening/domain/entities/screening.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository that orchestrates the inference process:
/// 1. Updates screening status to 'processing'
/// 2. Calls the inference service
/// 3. Saves the result to screening_results table
/// 4. Status auto-updates to 'completed' via database trigger
class InferenceRepository {
  final InferenceService inferenceService;
  final SupabaseClient _supabase = Supabase.instance.client;

  InferenceRepository({required this.inferenceService});

  /// Process a screening through the AI inference pipeline
  Future<void> processScreening(Screening screening) async {
    try {
      // 1. Update status to 'processing'
      await _updateScreeningStatus(screening.id, ScreeningStatus.processing);

      // 2. Run inference
      final result = await inferenceService.runInference(
        screeningId: screening.id,
        imageUrl: screening.imageUrl,
      );

      // 3. Save result to database
      await _saveInferenceResult(
        screeningId: screening.id,
        result: result,
      );

      // Note: Status will auto-update to 'completed' via database trigger
    } catch (e) {
      // On failure, update status to 'failed'
      await _updateScreeningStatus(screening.id, ScreeningStatus.failed);
      rethrow;
    }
  }

  Future<void> _updateScreeningStatus(
    String screeningId,
    ScreeningStatus status,
  ) async {
    await _supabase
        .from('screenings')
        .update({'status': status.name})
        .eq('id', screeningId);
  }

  Future<void> _saveInferenceResult({
    required String screeningId,
    required InferenceResult result,
  }) async {
    await _supabase.from('screening_results').insert({
      'screening_id': screeningId,
      'classification': result.classification.name,
      'confidence': result.confidence,
      'detections': result.detections?.map((d) => d.toJson()).toList(),
      'result_image_url': result.resultImageUrl,
      'model_version': result.modelVersion,
      'inference_time_ms': result.inferenceTimeMs,
    });
  }
}
