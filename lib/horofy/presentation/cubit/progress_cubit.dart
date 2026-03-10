import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/progress_entity.dart';
import '../../domain/usecases/progress_usecases.dart';
import 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  final SaveProgressUseCase saveProgressUseCase;
  final GetProgressForChildUseCase getProgressForChildUseCase;
  final GetProgressForLetterUseCase getProgressForLetterUseCase;
  final UpdateProgressUseCase updateProgressUseCase;

  ProgressCubit({
    required this.saveProgressUseCase,
    required this.getProgressForChildUseCase,
    required this.getProgressForLetterUseCase,
    required this.updateProgressUseCase,
  }) : super(ProgressInitial());

  Future<void> loadProgress(int childId, String level) async {
    emit(ProgressLoading());
    try {
      final progress = await getProgressForChildUseCase(childId, level);
      emit(ProgressLoaded(progress));
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }

  Future<void> markAsWritten(int childId, String level, int letterId) async {
    try {
      var progress = await getProgressForLetterUseCase(
        childId,
        level,
        letterId,
      );
      if (progress == null) {
        progress = ProgressEntity(
          childId: childId,
          level: level,
          letterId: letterId,
          written: true,
        );
        await saveProgressUseCase(progress);
      } else {
        final updated = ProgressEntity(
          id: progress.id,
          childId: progress.childId,
          level: progress.level,
          letterId: progress.letterId,
          listened: progress.listened,
          spoken: progress.spoken,
          written: true,
        );
        await updateProgressUseCase(updated);
      }
      // Reload progress
      await loadProgress(childId, level);
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }

  Future<void> markAsListened(int childId, String level, int letterId) async {
    try {
      var progress = await getProgressForLetterUseCase(
        childId,
        level,
        letterId,
      );
      if (progress == null) {
        progress = ProgressEntity(
          childId: childId,
          level: level,
          letterId: letterId,
          listened: true,
        );
        await saveProgressUseCase(progress);
      } else {
        final updated = ProgressEntity(
          id: progress.id,
          childId: progress.childId,
          level: progress.level,
          letterId: progress.letterId,
          listened: true,
          spoken: progress.spoken,
          written: progress.written,
        );
        await updateProgressUseCase(updated);
      }
      // Reload progress
      await loadProgress(childId, level);
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }
}
