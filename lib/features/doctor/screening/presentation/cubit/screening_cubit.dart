import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serfix/core/services/inference/inference_repository.dart';
import 'package:serfix/features/doctor/screening/domain/entities/screening.dart';
import 'package:serfix/features/doctor/screening/domain/repositories/screening_repository.dart';

part 'screening_state.dart';

class ScreeningCubit extends Cubit<ScreeningState> {
  final ScreeningRepository repository;
  final InferenceRepository? inferenceRepository;

  ScreeningCubit({
    required this.repository,
    this.inferenceRepository,
  }) : super(ScreeningInitial());

  Future<void> loadScreenings() async {
    try {
      emit(ScreeningLoading());
      final screenings = await repository.getScreenings();
      final stats = await repository.getScreeningStats();
      emit(ScreeningLoaded(screenings: screenings, stats: stats));
    } catch (e) {
      emit(ScreeningError(message: 'Failed to load screenings: $e'));
    }
  }

  Future<void> loadScreeningsByStatus(ScreeningStatus status) async {
    try {
      emit(ScreeningLoading());
      final screenings = await repository.getScreeningsByStatus(status);
      final stats = await repository.getScreeningStats();
      emit(ScreeningLoaded(
        screenings: screenings,
        stats: stats,
        filterStatus: status,
      ));
    } catch (e) {
      emit(ScreeningError(message: 'Failed to load screenings: $e'));
    }
  }

  Future<void> loadStats() async {
    try {
      final stats = await repository.getScreeningStats();
      final currentState = state;
      if (currentState is ScreeningLoaded) {
        emit(currentState.copyWith(stats: stats));
      } else {
        emit(ScreeningLoaded(screenings: const [], stats: stats));
      }
    } catch (e) {
      emit(ScreeningError(message: 'Failed to load stats: $e'));
    }
  }

  Future<void> createScreening({
    required File imageFile,
    String? patientIdentifier,
    int? patientAge,
    String? notes,
  }) async {
    try {
      emit(ScreeningCreating());
      final screening = await repository.createScreening(
        imageFile: imageFile,
        patientIdentifier: patientIdentifier,
        patientAge: patientAge,
        notes: notes,
      );
      emit(ScreeningCreated(screening: screening));

      // Trigger AI inference in background (if inference repository is available)
      if (inferenceRepository != null) {
        _runInferenceInBackground(screening);
      }

      // Reload list
      await loadScreenings();
    } catch (e) {
      emit(ScreeningError(message: 'Failed to create screening: $e'));
    }
  }

  /// Runs inference in background without blocking the UI
  void _runInferenceInBackground(Screening screening) async {
    try {
      await inferenceRepository!.processScreening(screening);
      // Reload to show updated results
      await loadScreenings();
    } catch (e) {
      // Inference failed - status will be 'failed' in DB
      // Just reload to reflect the failed state
      await loadScreenings();
    }
  }

  Future<void> deleteScreening(String id) async {
    try {
      await repository.deleteScreening(id);
      // Reload list
      await loadScreenings();
    } catch (e) {
      emit(ScreeningError(message: 'Failed to delete screening: $e'));
    }
  }

  Future<Screening?> getScreeningById(String id) async {
    try {
      return await repository.getScreeningById(id);
    } catch (e) {
      emit(ScreeningError(message: 'Failed to get screening: $e'));
      return null;
    }
  }

  /// Manually trigger inference for a pending screening
  Future<void> retryInference(Screening screening) async {
    if (inferenceRepository == null) {
      emit(const ScreeningError(message: 'Inference service not available'));
      return;
    }

    try {
      await inferenceRepository!.processScreening(screening);
      await loadScreenings();
    } catch (e) {
      emit(ScreeningError(message: 'Inference failed: $e'));
      await loadScreenings();
    }
  }
}
