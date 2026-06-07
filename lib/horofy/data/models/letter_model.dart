import '../../domain/entities/letter.dart';

class LetterModel extends Letter {

  LetterModel({
    required super.id,
    required super.letter,
    required super.letterAr,
    required super.letterEn,
    required super.image,
    required super.soundName,
    required super.soundLetter,
    super.listened = false,
    super.spoken = false,
    super.written = false,
  });

}