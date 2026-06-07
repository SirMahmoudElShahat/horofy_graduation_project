import '../entities/submission_entity.dart';

abstract class SubmissionRepository {
  Future<void> submit(SubmissionEntity submission);
  Future<List<SubmissionEntity>> getChildSubmissions(int childId);
}