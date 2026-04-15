import 'package:horofy/horofy/data/datasources/child_local_datasource.dart';
import 'package:horofy/horofy/data/datasources/child_remote_datasource.dart';
import 'package:horofy/horofy/data/models/child_model.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/repositories/child_repository.dart';

class ChildRepositoryImpl implements ChildRepository {
  final ChildLocalDataSource localDataSource;
  final ChildRemoteDataSource remoteDataSource;

  ChildRepositoryImpl({
    required this.localDataSource,
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
    try {
      final remoteChildren = await remoteDataSource.getChildren();
      await _syncRemoteToLocal(remoteChildren);
      // Return from local after sync so local IDs are always present
      return localDataSource.getChildren();
    } catch (_) {
      return localDataSource.getChildren();
    }
  }

  Future<void> _syncRemoteToLocal(List<ChildModel> remoteChildren) async {
    final localChildren = await localDataSource.getChildren();

    for (final remote in remoteChildren) {
      // Find by remoteId
      ChildEntity? existing;
      for (final local in localChildren) {
        if ((local as ChildModel).remoteId == remote.remoteId) {
          existing = local;
          break;
        }
      }

      if (existing == null) {
        await localDataSource.addChild(remote);
      } else {
        final updated = ChildModel(
          id: existing.id,
          remoteId: remote.remoteId,
          name: remote.name,
          birthDate: remote.birthDate,
          gender: remote.gender,
          avatar: remote.avatar,
          level: remote.level,
        );
        await localDataSource.updateChild(updated);
      }
    }
  }

  // ── ADD ───────────────────────────────────────────────────
  @override
  Future<void> addChild(ChildEntity child) async {
    final model = _toModel(child);
    // Always use remote API - no local fallback
    final created = await remoteDataSource.createChild(model);
    await localDataSource.addChild(created);
  }

  // ── UPDATE ────────────────────────────────────────────────
  @override
  Future<void> updateChild(ChildEntity child) async {
    final model = _toModel(child);
    try {
      if (model.remoteId != null) {
        final updated = await remoteDataSource.updateChild(model);
        final localModel = ChildModel(
          id: model.id,
          remoteId: updated.remoteId,
          name: updated.name,
          birthDate: updated.birthDate,
          gender: updated.gender,
          avatar: updated.avatar,
          level: updated.level,
        );
        await localDataSource.updateChild(localModel);
      } else {
        // If no remoteId, create as new on server
        final created = await remoteDataSource.createChild(model);
        final localModel = ChildModel(
          id: model.id,
          remoteId: created.remoteId,
          name: created.name,
          birthDate: created.birthDate,
          gender: created.gender,
          avatar: created.avatar,
          level: created.level,
        );
        await localDataSource.updateChild(localModel);
      }
    } catch (_) {
      await localDataSource.updateChild(model);
    }
  }

  // ── DELETE ────────────────────────────────────────────────
  @override
  Future<void> deleteChild(int localId) async {
    // Step 1: get remoteId BEFORE deleting locally
    final localChildren = await localDataSource.getChildren();

    String? remoteId;
    for (final child in localChildren) {
      if (child.id == localId) {
        remoteId = (child as ChildModel).remoteId;
        break;
      }
    }

    // Step 2: delete from server first (if remoteId exists)
    if (remoteId != null) {
      try {
        await remoteDataSource.deleteChild(remoteId);
      } catch (_) {
        // Server delete failed — still delete locally
      }
    }

    // Step 3: delete from local DB
    await localDataSource.deleteChild(localId);
  }
}
