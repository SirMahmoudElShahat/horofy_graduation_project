class Letter {

  final int id;
  final String letter;
  final String letterAr;
  final String letterEn;
  final String image;
  final String soundName;
  final String soundLetter;

  final bool listened;
  final bool spoken;
  final bool written;

  Letter({
    required this.id,
    required this.letter,
    required this.letterAr,
    required this.letterEn,
    required this.image,
    required this.soundName,
    required this.soundLetter,
    this.listened = false,
    this.spoken = false,
    this.written = false,
  });

}