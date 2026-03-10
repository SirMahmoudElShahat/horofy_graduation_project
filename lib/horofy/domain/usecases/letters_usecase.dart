import '../entities/letter.dart';
import '../repositories/letters_repository.dart';

class GetLettersUseCase {

  final LettersRepository repository;

  GetLettersUseCase(this.repository);

  List<Letter> call() {
    return repository.getLetters();
  }

}