import '../../../../core/database/app_database.dart';
import '../models/child_model.dart';

abstract class ChildLocalDataSource {

  Future<void> addChild(ChildModel child);

  Future<List<ChildModel>> getChildren();

  Future<void> deleteChild(int id);

  Future<void> updateChild(ChildModel child);
}

class ChildLocalDataSourceImpl
    implements ChildLocalDataSource {

  @override
  Future<void> addChild(ChildModel child) async {
    final db = await AppDatabase.database;

    await db.insert('children', child.toMap());
  }

  @override
  Future<List<ChildModel>> getChildren() async {
    final db = await AppDatabase.database;

    final result = await db.query('children');

    return result
        .map((e) => ChildModel.fromMap(e))
        .toList();
  }

  @override
  Future<void> deleteChild(int id) async {
    final db = await AppDatabase.database;

    await db.delete(
      'children',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> updateChild(ChildModel child) async {
    final db = await AppDatabase.database;

    await db.update(
      'children',
      child.toMap(),
      where: 'id = ?',
      whereArgs: [child.id],
    );
  }
}
