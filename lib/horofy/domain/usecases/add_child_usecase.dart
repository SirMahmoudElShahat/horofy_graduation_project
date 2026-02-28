import '../entities/child_entity.dart';
import '../repositories/child_repository.dart';

class AddChildUseCase {

  final ChildRepository repository;

  AddChildUseCase(this.repository);

  Future<void> call(ChildEntity child) {
    return repository.addChild(child);
  }
}

class GetChildrenUseCase {
  final ChildRepository repository;

  GetChildrenUseCase(this.repository);

  Future<List<ChildEntity>> call() {
    return repository.getChildren();
  }
}

class DeleteChildUseCase {
  final ChildRepository repository;

  DeleteChildUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteChild(id);
  }
}

class UpdateChildUseCase {
  final ChildRepository repository;

  UpdateChildUseCase(this.repository);

  Future<void> call(ChildEntity child) {
    return repository.updateChild(child);
  }
}

