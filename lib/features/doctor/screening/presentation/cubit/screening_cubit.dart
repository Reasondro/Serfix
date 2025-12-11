import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serfix/features/doctor/screening/domain/entities/screening.dart';
import 'package:serfix/features/doctor/screening/domain/repositories/screening_repository.dart';

part 'screening_state.dart';

class ScreeningCubit extends Cubit<ScreeningState> {
  final ScreeningRepository repository;

  ScreeningCubit({required this.repository}) : super(ScreeningInitial());

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
      // Reload list
      await loadScreenings();
    } catch (e) {
      emit(ScreeningError(message: 'Failed to create screening: $e'));
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
}
