import '../../../../core/database/app_database.dart';
import '../models/progress_model.dart';

abstract class ProgressLocalDataSource {
  Future<void> saveProgress(ProgressModel progress);
  Future<List<ProgressModel>> getProgressForChild(int childId, String level);
  Future<ProgressModel?> getProgressForLetter(
    int childId,
    String level,
    int letterId,
  );
  Future<void> updateProgress(ProgressModel progress);
}

class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  @override
  Future<void> saveProgress(ProgressModel progress) async {
    final db = await AppDatabase.database;
    await db.insert('progress', progress.toMap());
  }

  @override
  Future<List<ProgressModel>> getProgressForChild(
    int childId,
    String level,
  ) async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'progress',
      where: 'childId = ? AND level = ?',
      whereArgs: [childId, level],
    );
    return result.map((e) => ProgressModel.fromMap(e)).toList();
  }

  @override
  Future<ProgressModel?> getProgressForLetter(
    int childId,
    String level,
    int letterId,
  ) async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'progress',
      where: 'childId = ? AND level = ? AND letterId = ?',
      whereArgs: [childId, level, letterId],
    );
    if (result.isNotEmpty) {
      return ProgressModel.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<void> updateProgress(ProgressModel progress) async {
    final db = await AppDatabase.database;
    await db.update(
      'progress',
      progress.toMap(),
      where: 'id = ?',
      whereArgs: [progress.id],
    );
  }
}
