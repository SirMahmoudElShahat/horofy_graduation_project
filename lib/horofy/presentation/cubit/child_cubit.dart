import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/usecases/add_child_usecase.dart';
import 'child_state.dart';

class ChildCubit extends Cubit<ChildState> {
  final AddChildUseCase addChild;
  final GetChildrenUseCase getChildrenUseCase;
  final DeleteChildUseCase deleteChildUseCase;
  final UpdateChildUseCase updateChildUseCase;

  ChildCubit(
    AddChildUseCase addChildUseCase, {
    required this.addChild,
    required this.getChildrenUseCase,
    required this.deleteChildUseCase,
    required this.updateChildUseCase,
  }) : super(ChildInitial());

  /// ADD
  Future<void> addNewChild(ChildEntity child) async {
    try {
      emit(ChildAddLoading());
      await addChild(child);
      emit(ChildAddSuccess());
      await loadChildren();
    } catch (e) {
      emit(ChildAddError(e.toString()));
    }
  }

  /// GET LIST
  Future<void> loadChildren() async {
    try {
      emit(ChildLoading());

      final children = await getChildrenUseCase();

      emit(ChildLoaded(children));
    } catch (e) {
      // If fetching fails (e.g. DB not ready), emit an empty list to keep UI stable
      emit(const ChildLoaded([]));
    }
  }

  /// DELETE
  Future<void> deleteChild(int id) async {
    await deleteChildUseCase(id);
    loadChildren();
  }

  /// UPDATE
  Future<void> updateChild(ChildEntity child) async {
    try {
      emit(ChildUpdateLoading());
      await updateChildUseCase(child);
      emit(ChildUpdateSuccess());
      await loadChildren();
    } catch (e) {
      emit(ChildUpdateError(e.toString()));
    }
  }

  /// GET CURRENT LEVEL FOR A CHILD
  Future<String?> getCurrentLevel(int childId) async {
    try {
      final children = await getChildrenUseCase();
      for (final c in children) {
        if (c.id == childId) return c.level;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// UPDATE LEVEL FOR A CHILD (keeps other fields)
  Future<void> updateLevel(int childId, String newLevel) async {
    try {
      final children = await getChildrenUseCase();
      ChildEntity? found;
      for (final c in children) {
        if (c.id == childId) {
          found = c;
          break;
        }
      }
      if (found == null) return;

      final updated = ChildEntity(
        id: found.id,
        name: found.name,
        birthDate: found.birthDate,
        gender: found.gender,
        avatar: found.avatar,
        level: newLevel,
      );

      await updateChild(updated);
    } catch (e) {
      emit(ChildUpdateError(e.toString()));
    }
  }
}
