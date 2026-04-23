import '../entities/submission_entity.dart';
import '../repositories/submission_repository.dart';

class SubmitExerciseUseCase {
  final SubmissionRepository repository;
  SubmitExerciseUseCase(this.repository);

  Future<void> call(SubmissionEntity submission) => repository.submit(submission);
}

class GetChildSubmissionsUseCase {
  final SubmissionRepository repository;
  GetChildSubmissionsUseCase(this.repository);

  Future<List<SubmissionEntity>> call(int childId) =>
      repository.getChildSubmissions(childId);
}