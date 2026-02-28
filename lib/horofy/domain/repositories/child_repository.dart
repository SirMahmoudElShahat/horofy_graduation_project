import '../entities/child_entity.dart';

abstract class ChildRepository {

  Future<void> addChild(ChildEntity child);

  Future<List<ChildEntity>> getChildren();

  Future<void> deleteChild(int id);

  Future<void> updateChild(ChildEntity child);
}
