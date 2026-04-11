import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/usecases/add_child_usecase.dart';
import 'child_state.dart';

class ChildCubit extends Cubit<ChildState> {
  final AddChildUseCase addChild;
  final GetChildrenUseCase getChildrenUseCase;
  final DeleteChildUseCase deleteChildUseCase;
  final UpdateChildUseCase updateChildUseCase;

  // Constructor fixed — no duplicate positional parameter
  ChildCubit({
    required this.addChild,
    required this.getChildrenUseCase,
    required this.deleteChildUseCase,
    required this.updateChildUseCase,
  }) : super(ChildInitial());

  // ── ADD ───────────────────────────────────────────────────
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

  // ── GET LIST ──────────────────────────────────────────────
  Future<void> loadChildren() async {
    try {
      emit(ChildLoading());
      final children = await getChildrenUseCase();
      emit(ChildLoaded(children));
    } catch (e) {
      emit(const ChildLoaded([]));
    }
  }

  // ── DELETE ────────────────────────────────────────────────
  Future<void> deleteChild(int id) async {
    await deleteChildUseCase(id);
    await loadChildren();
  }

  // ── UPDATE ────────────────────────────────────────────────
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

  // ── UPDATE LEVEL — silent, no UI state change ─────────────
  // Calls use case directly to avoid ChildUpdateLoading flickering the UI
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
        remoteId: found.remoteId,
        name: found.name,
        birthDate: found.birthDate,
        gender: found.gender,
        avatar: found.avatar,
        level: newLevel,
      );

      // Direct use case call — no emit to avoid UI disruption
      await updateChildUseCase(updated);
      // Reload children to sync with server after update
      await loadChildren();
    } catch (e) {
      emit(ChildUpdateError(e.toString()));
    }
  }

  // ── GET CURRENT LEVEL ─────────────────────────────────────
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
}