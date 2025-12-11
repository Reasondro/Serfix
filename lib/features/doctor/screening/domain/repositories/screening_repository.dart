import 'dart:io';

import 'package:serfix/features/doctor/screening/domain/entities/screening.dart';

abstract class ScreeningRepository {
  /// Get all screenings for the current doctor
  Future<List<Screening>> getScreenings();

  /// Get a single screening by ID
  Future<Screening?> getScreeningById(String id);

  /// Get screenings filtered by status
  Future<List<Screening>> getScreeningsByStatus(ScreeningStatus status);

  /// Get screening statistics for dashboard
  Future<ScreeningStats> getScreeningStats();

  /// Create a new screening
  Future<Screening> createScreening({
    required File imageFile,
    String? patientIdentifier,
    int? patientAge,
    String? notes,
  });

  /// Update a screening
  Future<Screening> updateScreening({
    required String id,
    String? patientIdentifier,
    int? patientAge,
    String? notes,
    ScreeningStatus? status,
  });

  /// Delete a screening
  Future<void> deleteScreening(String id);
}

class ScreeningStats {
  final int todayCount;
  final int pendingCount;
  final int completedThisWeek;
  final int abnormalCount;

  const ScreeningStats({
    required this.todayCount,
    required this.pendingCount,
    required this.completedThisWeek,
    required this.abnormalCount,
  });

  factory ScreeningStats.empty() {
    return const ScreeningStats(
      todayCount: 0,
      pendingCount: 0,
      completedThisWeek: 0,
      abnormalCount: 0,
    );
  }
}
