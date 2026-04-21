import '../../domain/entities/submission_entity.dart';
import '../../domain/repositories/submission_repository.dart';
import '../datasources/submission_remote_datasource.dart';
import '../models/submission_model.dart';

class SubmissionRepositoryImpl implements SubmissionRepository {
  final SubmissionRemoteDataSource remoteDataSource;

  SubmissionRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> submit(SubmissionEntity submission) async {
    final model = SubmissionModel.fromEntity(submission);
    await remoteDataSource.createSubmission(model);
  }

  @override
  Future<List<SubmissionEntity>> getChildSubmissions(int childId) async {
    final models = await remoteDataSource.getChildSubmissions(childId);
    return models.map((m) => m.toEntity()).toList();
  }
}