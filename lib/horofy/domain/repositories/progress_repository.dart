import '../entities/progress_entity.dart';

abstract class ProgressRepository {
  Future<void> saveProgress(ProgressEntity progress);
  Future<List<ProgressEntity>> getProgressForChild(int childId, String level);
  Future<ProgressEntity?> getProgressForLetter(
    int childId,
    String level,
    int letterId,
  );
  Future<void> updateProgress(ProgressEntity progress);
}
