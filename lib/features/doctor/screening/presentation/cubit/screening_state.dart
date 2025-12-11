part of 'screening_cubit.dart';

sealed class ScreeningState extends Equatable {
  const ScreeningState();

  @override
  List<Object?> get props => [];
}

final class ScreeningInitial extends ScreeningState {}

final class ScreeningLoading extends ScreeningState {}

final class ScreeningCreating extends ScreeningState {}

final class ScreeningLoaded extends ScreeningState {
  final List<Screening> screenings;
  final ScreeningStats stats;
  final ScreeningStatus? filterStatus;

  const ScreeningLoaded({
    required this.screenings,
    required this.stats,
    this.filterStatus,
  });

  ScreeningLoaded copyWith({
    List<Screening>? screenings,
    ScreeningStats? stats,
    ScreeningStatus? filterStatus,
  }) {
    return ScreeningLoaded(
      screenings: screenings ?? this.screenings,
      stats: stats ?? this.stats,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }

  @override
  List<Object?> get props => [screenings, stats, filterStatus];
}

final class ScreeningCreated extends ScreeningState {
  final Screening screening;

  const ScreeningCreated({required this.screening});

  @override
  List<Object?> get props => [screening];
}

final class ScreeningError extends ScreeningState {
  final String message;

  const ScreeningError({required this.message});

  @override
  List<Object?> get props => [message];
}
