class WordLetter {
  final int letterId;
  final String letter;
  final String image;
  final String sound;
  final bool isMadLetter;

  const WordLetter({
    required this.letterId,
    required this.letter,
    required this.image,
    required this.sound,
    this.isMadLetter = false,
  });
}

class MadLetter {
  final int id;
  final String letter;
  final String letterAr;
  final String image;
  final String sound;
  final String wordText;
  final String wordImage;
  final List<WordLetter> wordLetters;

  const MadLetter({
    required this.id,
    required this.letter,
    required this.letterAr,
    required this.image,
    required this.sound,
    required this.wordText,
    required this.wordImage,
    required this.wordLetters,
  });
}