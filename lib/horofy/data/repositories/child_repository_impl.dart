import 'package:horofy/horofy/data/datasources/child_local_datasource.dart';
import 'package:horofy/horofy/data/models/child_model.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/repositories/child_repository.dart';

class ChildRepositoryImpl implements ChildRepository {

  final ChildLocalDataSource localDataSource;

  ChildRepositoryImpl(this.localDataSource);

  @override
  Future<void> addChild(ChildEntity child) async {
    await localDataSource.addChild(
      ChildModel(
        name: child.name,
        birthDate: child.birthDate,
        gender: child.gender,
        avatar: child.avatar,
      ),
    );
  }

  @override
  Future<List<ChildEntity>> getChildren() {
    return localDataSource.getChildren();
  }

  @override
  Future<void> deleteChild(int id) {
    return localDataSource.deleteChild(id);
  }

  @override
  Future<void> updateChild(ChildEntity child) {
    return localDataSource.updateChild(
      ChildModel(
        id: child.id,
        name: child.name,
        birthDate: child.birthDate,
        gender: child.gender,
        avatar: child.avatar,
      ),
    );
  }
}
