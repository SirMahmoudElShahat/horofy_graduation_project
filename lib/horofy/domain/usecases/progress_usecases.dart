import '../entities/progress_entity.dart';
import '../repositories/progress_repository.dart';

class SaveProgressUseCase {
  final ProgressRepository repository;

  SaveProgressUseCase(this.repository);

  Future<void> call(ProgressEntity progress) async {
    return await repository.saveProgress(progress);
  }
}

class GetProgressForChildUseCase {
  final ProgressRepository repository;

  GetProgressForChildUseCase(this.repository);

  Future<List<ProgressEntity>> call(int childId, String level) async {
    return await repository.getProgressForChild(childId, level);
  }
}

class GetProgressForLetterUseCase {
  final ProgressRepository repository;

  GetProgressForLetterUseCase(this.repository);

  Future<ProgressEntity?> call(int childId, String level, int letterId) async {
    return await repository.getProgressForLetter(childId, level, letterId);
  }
}

class UpdateProgressUseCase {
  final ProgressRepository repository;

  UpdateProgressUseCase(this.repository);

  Future<void> call(ProgressEntity progress) async {
    return await repository.updateProgress(progress);
  }
}
