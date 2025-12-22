import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serfix/core/services/inference/inference_repository.dart';
import 'package:serfix/features/doctor/screening/domain/entities/screening.dart';
import 'package:serfix/features/doctor/screening/domain/repositories/screening_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'screening_state.dart';

class ScreeningCubit extends Cubit<ScreeningState> {
  final ScreeningRepository repository;
  final InferenceRepository? inferenceRepository;
  final SupabaseClient _supabase = Supabase.instance.client;

  RealtimeChannel? _screeningsChannel;
  RealtimeChannel? _resultsChannel;
  bool _isSubscribed = false;

  ScreeningCubit({
    required this.repository,
    this.inferenceRepository,
  }) : super(ScreeningInitial());

  /// Subscribe to real-time updates for screenings
  void subscribeToRealtimeUpdates() {
    if (_isSubscribed) return;

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Subscribe to screenings table changes
    _screeningsChannel = _supabase
        .channel('screenings_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'screenings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'doctor_id',
            value: userId,
          ),
          callback: (payload) {
            _handleScreeningChange(payload);
          },
        )
        .subscribe();

    // Subscribe to screening_results table changes
    _resultsChannel = _supabase
        .channel('results_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'screening_results',
          callback: (payload) {
            _handleResultChange(payload);
          },
        )
        .subscribe();

    _isSubscribed = true;
  }

  void _handleScreeningChange(PostgresChangePayload payload) {
    // Reload data when screening changes
    _silentReload();
  }

  void _handleResultChange(PostgresChangePayload payload) {
    // Reload data when result is added/updated
    _silentReload();
  }

  /// Reload without showing loading state (for real-time updates)
  Future<void> _silentReload() async {
    try {
      final screenings = await repository.getScreenings();
      final stats = await repository.getScreeningStats();

      final currentState = state;
      if (currentState is ScreeningLoaded) {
        emit(ScreeningLoaded(
          screenings: screenings,
          stats: stats,
          filterStatus: currentState.filterStatus,
        ));
      } else {
        emit(ScreeningLoaded(screenings: screenings, stats: stats));
      }
    } catch (e) {
      // Silently fail for background updates
    }
  }

  /// Unsubscribe from real-time updates
  void unsubscribeFromRealtimeUpdates() {
    _screeningsChannel?.unsubscribe();
    _resultsChannel?.unsubscribe();
    _screeningsChannel = null;
    _resultsChannel = null;
    _isSubscribed = false;
  }

  @override
  Future<void> close() {
    unsubscribeFromRealtimeUpdates();
    return super.close();
  }

  Future<void> loadScreenings() async {
    try {
      emit(ScreeningLoading());
      final screenings = await repository.getScreenings();
      final stats = await repository.getScreeningStats();
      emit(ScreeningLoaded(screenings: screenings, stats: stats));

      // Subscribe to real-time updates after initial load
      subscribeToRealtimeUpdates();
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
      // Real-time subscription will handle the UI update
    } catch (e) {
      // Inference failed - real-time subscription will handle the UI update
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
      // Real-time subscription will handle the UI update
    } catch (e) {
      emit(ScreeningError(message: 'Inference failed: $e'));
      await loadScreenings();
    }
  }
}
