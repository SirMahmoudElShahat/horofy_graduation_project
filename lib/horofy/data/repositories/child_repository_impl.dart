import 'package:horofy/horofy/data/datasources/child_remote_datasource.dart';
import 'package:horofy/horofy/data/models/child_model.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/repositories/child_repository.dart';

class ChildRepositoryImpl implements ChildRepository {
  final ChildRemoteDataSource remoteDataSource;

  ChildRepositoryImpl({
    required this.remoteDataSource,
  });

  ChildModel _toModel(ChildEntity child) {
    return ChildModel(
      id: child.id,
      remoteId: child.remoteId,
      name: child.name,
      birthDate: child.birthDate,
      gender: child.gender,
      avatar: child.avatar,
      level: child.level,
    );
  }

  // ── GET ───────────────────────────────────────────────────
  @override
  Future<List<ChildEntity>> getChildren() async {
    return await remoteDataSource.getChildren();
  }

  // ── ADD ───────────────────────────────────────────────────
  @override
  Future<void> addChild(ChildEntity child) async {
    final model = _toModel(child);
    await remoteDataSource.createChild(model);
  }

  // ── UPDATE ────────────────────────────────────────────────
  @override
  Future<void> updateChild(ChildEntity child) async {
    final model = _toModel(child);
    if (model.remoteId != null) {
      await remoteDataSource.updateChild(model);
    } else {
      await remoteDataSource.createChild(model);
    }
  }

  // ── DELETE ────────────────────────────────────────────────
  @override
  Future<void> deleteChild(int id) async {
    // remoteId might be a string but usually matches the int id
    // Assuming remoteId is the same as the id mapped in ChildModel
    await remoteDataSource.deleteChild(id.toString());
  }
}
