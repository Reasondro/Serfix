import 'package:equatable/equatable.dart';

enum Classification {
  normal,
  abnormal,
  inconclusive;

  static Classification fromString(String value) {
    return Classification.values.firstWhere(
      (c) => c.name == value,
      orElse: () => Classification.inconclusive,
    );
  }

  String get displayName {
    switch (this) {
      case Classification.normal:
        return 'Normal';
      case Classification.abnormal:
        return 'Abnormal';
      case Classification.inconclusive:
        return 'Inconclusive';
    }
  }
}

class Detection extends Equatable {
  final String label;
  final double confidence;
  final List<int>? bbox; // [x, y, width, height]
  final String? severity;

  const Detection({
    required this.label,
    required this.confidence,
    this.bbox,
    this.severity,
  });

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      bbox: json['bbox'] != null
          ? (json['bbox'] as List).map((e) => e as int).toList()
          : null,
      severity: json['severity'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'bbox': bbox,
      'severity': severity,
    };
  }

  @override
  List<Object?> get props => [label, confidence, bbox, severity];
}

class ScreeningResult extends Equatable {
  final String id;
  final String screeningId;
  final Classification classification;
  final double? confidence;
  final List<Detection>? detections;
  final String? resultImageUrl;
  final String? modelVersion;
  final int? inferenceTimeMs;
  final DateTime createdAt;

  const ScreeningResult({
    required this.id,
    required this.screeningId,
    required this.classification,
    this.confidence,
    this.detections,
    this.resultImageUrl,
    this.modelVersion,
    this.inferenceTimeMs,
    required this.createdAt,
  });

  factory ScreeningResult.fromJson(Map<String, dynamic> json) {
    List<Detection>? detections;
    if (json['detections'] != null) {
      detections = (json['detections'] as List)
          .map((d) => Detection.fromJson(d as Map<String, dynamic>))
          .toList();
    }

    return ScreeningResult(
      id: json['id'] as String,
      screeningId: json['screening_id'] as String,
      classification: Classification.fromString(json['classification'] as String),
      confidence: json['confidence'] != null
          ? (json['confidence'] as num).toDouble()
          : null,
      detections: detections,
      resultImageUrl: json['result_image_url'] as String?,
      modelVersion: json['model_version'] as String?,
      inferenceTimeMs: json['inference_time_ms'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screening_id': screeningId,
      'classification': classification.name,
      'confidence': confidence,
      'detections': detections?.map((d) => d.toJson()).toList(),
      'result_image_url': resultImageUrl,
      'model_version': modelVersion,
      'inference_time_ms': inferenceTimeMs,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        screeningId,
        classification,
        confidence,
        detections,
        resultImageUrl,
        modelVersion,
        inferenceTimeMs,
        createdAt,
      ];
}
