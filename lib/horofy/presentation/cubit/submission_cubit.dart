import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/submission_entity.dart';
import '../../domain/usecases/submission_usecases.dart';
import 'submission_state.dart';

class SubmissionCubit extends Cubit<SubmissionState> {
  final SubmitExerciseUseCase submitExerciseUseCase;
  final GetChildSubmissionsUseCase getChildSubmissionsUseCase;

  SubmissionCubit({
    required this.submitExerciseUseCase,
    required this.getChildSubmissionsUseCase,
  }) : super(SubmissionInitial());

  // ── Load all submissions for a child at level entry ───────────────────────
  // Called once when the child enters any level screen.
  // The screen then reads the state to determine where to resume.
  Future<void> loadChildSubmissions(int childId) async {
    emit(SubmissionLoading());
    try {
      final submissions = await getChildSubmissionsUseCase(childId);
      emit(SubmissionsLoaded(submissions));
    } catch (e) {
      // Emit empty list on failure so the level starts from the beginning
      emit(const SubmissionsLoaded([]));
    }
  }

  // ── Submit exercise result (silent — never blocks level flow) ─────────────
  // Errors are swallowed so a network failure never blocks the child.
  Future<void> submit({
    required int childId,
    required String level,
    required String exerciseType,
    required int exerciseId,
    String status = 'pass',
    int attemptsCount = 1,
    int duration = 0,
    int totalItems = 1,
    List<String> mistakes = const [],
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      await submitExerciseUseCase(
        SubmissionEntity(
          childId: childId,
          level: level,
          exerciseType: exerciseType,
          exerciseId: exerciseId,
          status: status,
          attemptsCount: attemptsCount,
          duration: duration,
          totalItems: totalItems,
          mistakes: mistakes,
          metadata: metadata,
        ),
      );
    } catch (_) {
      // Silent — do not emit error to avoid disrupting the level flow
    }
  }
}