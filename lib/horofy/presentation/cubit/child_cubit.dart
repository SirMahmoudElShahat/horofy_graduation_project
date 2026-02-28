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
    emit(ChildLoading());

    final children = await getChildrenUseCase();

    emit(ChildLoaded(children));
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
}
