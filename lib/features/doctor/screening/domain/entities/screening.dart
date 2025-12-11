import 'package:equatable/equatable.dart';
import 'package:serfix/features/doctor/screening/domain/entities/screening_result.dart';

enum ScreeningStatus {
  pending,
  processing,
  completed,
  failed;

  static ScreeningStatus fromString(String value) {
    return ScreeningStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ScreeningStatus.pending,
    );
  }
}

class Screening extends Equatable {
  final String id;
  final String doctorId;
  final String? patientIdentifier;
  final int? patientAge;
  final String? notes;
  final String imageUrl;
  final ScreeningStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ScreeningResult? result;

  const Screening({
    required this.id,
    required this.doctorId,
    this.patientIdentifier,
    this.patientAge,
    this.notes,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.result,
  });

  factory Screening.fromJson(Map<String, dynamic> json) {
    return Screening(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String,
      patientIdentifier: json['patient_identifier'] as String?,
      patientAge: json['patient_age'] as int?,
      notes: json['notes'] as String?,
      imageUrl: json['image_url'] as String,
      status: ScreeningStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      result: json['screening_results'] != null &&
              (json['screening_results'] is List
                  ? (json['screening_results'] as List).isNotEmpty
                  : true)
          ? ScreeningResult.fromJson(
              json['screening_results'] is List
                  ? (json['screening_results'] as List).first
                  : json['screening_results'],
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'patient_identifier': patientIdentifier,
      'patient_age': patientAge,
      'notes': notes,
      'image_url': imageUrl,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Screening copyWith({
    String? id,
    String? doctorId,
    String? patientIdentifier,
    int? patientAge,
    String? notes,
    String? imageUrl,
    ScreeningStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    ScreeningResult? result,
  }) {
    return Screening(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientIdentifier: patientIdentifier ?? this.patientIdentifier,
      patientAge: patientAge ?? this.patientAge,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [
        id,
        doctorId,
        patientIdentifier,
        patientAge,
        notes,
        imageUrl,
        status,
        createdAt,
        updatedAt,
        result,
      ];
}
