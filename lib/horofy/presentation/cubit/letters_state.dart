import '../../domain/entities/letter.dart';

abstract class LettersState {}

class LettersInitial extends LettersState {}

class LettersLoaded extends LettersState {

  final List<Letter> letters;

  LettersLoaded(this.letters);

}