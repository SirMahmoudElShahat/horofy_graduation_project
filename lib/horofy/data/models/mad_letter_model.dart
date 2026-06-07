import 'package:horofy/horofy/domain/entities/mad_letter.dart';

class WordLetterModel extends WordLetter {
  const WordLetterModel({
    required super.letterId,
    required super.letter,
    required super.image,
    required super.sound,
    super.isMadLetter = false,
  });
}

class MadLetterModel extends MadLetter {
  const MadLetterModel({
    required super.id,
    required super.letter,
    required super.letterAr,
    required super.image,
    required super.sound,
    required super.wordText,
    required super.wordImage,
    required super.wordLetters,
  });
}