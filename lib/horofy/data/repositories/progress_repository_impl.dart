import '../../domain/entities/progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_datasource.dart';
import '../models/progress_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressLocalDataSource dataSource;

  ProgressRepositoryImpl(this.dataSource);

  @override
  Future<void> saveProgress(ProgressEntity progress) async {
    final model = ProgressModel(
      id: progress.id,
      childId: progress.childId,
      level: progress.level,
      letterId: progress.letterId,
      listened: progress.listened,
      spoken: progress.spoken,
      written: progress.written,
    );
    await dataSource.saveProgress(model);
  }

  @override
  Future<List<ProgressEntity>> getProgressForChild(
    int childId,
    String level,
  ) async {
    final models = await dataSource.getProgressForChild(childId, level);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ProgressEntity?> getProgressForLetter(
    int childId,
    String level,
    int letterId,
  ) async {
    final model = await dataSource.getProgressForLetter(
      childId,
      level,
      letterId,
    );
    return model?.toEntity();
  }

  @override
  Future<void> updateProgress(ProgressEntity progress) async {
    final model = ProgressModel(
      id: progress.id,
      childId: progress.childId,
      level: progress.level,
      letterId: progress.letterId,
      listened: progress.listened,
      spoken: progress.spoken,
      written: progress.written,
    );
    await dataSource.updateProgress(model);
  }
}
