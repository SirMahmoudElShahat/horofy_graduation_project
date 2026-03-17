import 'package:horofy/horofy/domain/entities/mad_letter.dart';
import 'package:horofy/horofy/domain/repositories/mad_letters_repository.dart';

class GetMadLettersUseCase {
  final MadLettersRepository repository;

  GetMadLettersUseCase(this.repository);

  List<MadLetter> call() => repository.getMadLetters();
}