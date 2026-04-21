import 'package:equatable/equatable.dart';
import '../../domain/entities/submission_entity.dart';

abstract class SubmissionState extends Equatable {
  const SubmissionState();

  @override
  List<Object?> get props => [];
}

class SubmissionInitial extends SubmissionState {}

class SubmissionLoading extends SubmissionState {}

class SubmissionSuccess extends SubmissionState {}

class SubmissionError extends SubmissionState {
  final String message;

  const SubmissionError(this.message);

  @override
  List<Object?> get props => [message];
}

class SubmissionsLoaded extends SubmissionState {
  final List<SubmissionEntity> submissions;

  const SubmissionsLoaded(this.submissions);

  List<SubmissionEntity> submissionsForLevel(
    String level, {
    String? status,
    String? exerciseType,
  }) {
    return submissions.where((s) {
      final matchesLevel = s.level == level;
      final matchesStatus = status == null || s.status == status;
      final matchesExerciseType =
          exerciseType == null || s.exerciseType == exerciseType;
      return matchesLevel && matchesStatus && matchesExerciseType;
    }).toList();
  }

  /// Returns passed exercise IDs for a specific level.
  /// Used by levels to know where the child left off.
  Set<int> completedExerciseIds(String level, {String? exerciseType}) {
    return submissionsForLevel(
          level,
          status: 'pass',
          exerciseType: exerciseType,
        )
        .map((s) => s.exerciseId ?? 0)
        .where((id) => id > 0)
        .toSet();
  }

  /// Returns true if the given level has at least one passed submission.
  bool hasCompletedLevel(String level, {String? exerciseType}) {
    return submissionsForLevel(
      level,
      status: 'pass',
      exerciseType: exerciseType,
    ).isNotEmpty;
  }

  @override
  List<Object?> get props => [submissions];
}
