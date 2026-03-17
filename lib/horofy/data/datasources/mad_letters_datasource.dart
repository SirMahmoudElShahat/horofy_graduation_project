import 'package:horofy/horofy/data/models/mad_letter_model.dart';

abstract class MadLettersDataSource {
  List<MadLetterModel> getMadLetters();
}

class MadLettersDataSourceImpl implements MadLettersDataSource {
  @override
  List<MadLetterModel> getMadLetters() {
    return [
      // ── حرف الألف ── كلمة: بَاب
      MadLetterModel(
        id: 1,
        letter: 'ا',
        letterAr: 'ألف المد',
        image: 'assets/images/level2/alif.png',
        sound: 'assets/sounds/letter_name/alif.mp3',
        wordText: 'بَاب',
        wordImage: 'assets/images/level2/door.png',
        wordLetters: const [
          WordLetterModel(
            letterId: 2,
            letter: 'بَ',
            image: 'assets/images/letters/2.png',
            sound: 'assets/sounds/letter_sound/ba.mp3',
          ),
          WordLetterModel(
            letterId: 1,
            letter: 'ا',
            image: 'assets/images/letters/1.png',
            sound: 'assets/sounds/letter_sound/alif.mp3',
            isMadLetter: true,
          ),
          WordLetterModel(
            letterId: 2,
            letter: 'بْ',
            image: 'assets/images/letters/2.png',
            sound: 'assets/sounds/letter_sound/ba.mp3',
          ),
        ],
      ),

      // ── حرف الواو ── كلمة: بُوق
      MadLetterModel(
        id: 2,
        letter: 'و',
        letterAr: 'واو المد',
        image: 'assets/images/level2/waw.png',
        sound: 'assets/sounds/letter_name/waw.mp3',
        wordText: 'بُوق',
        wordImage: 'assets/images/level2/brass.png',
        wordLetters: const [
          WordLetterModel(
            letterId: 2,
            letter: 'بُ',
            image: 'assets/images/letters/2.png',
            sound: 'assets/sounds/letter_sound/ba.mp3',
          ),
          WordLetterModel(
            letterId: 27,
            letter: 'و',
            image: 'assets/images/letters/27.png',
            sound: 'assets/sounds/letter_sound/waw.mp3',
            isMadLetter: true,
          ),
          WordLetterModel(
            letterId: 21,
            letter: 'قْ',
            image: 'assets/images/letters/21.png',
            sound: 'assets/sounds/letter_sound/qaf.mp3',
          ),
        ],
      ),

      // ── حرف الياء ── كلمة: بِيت
      MadLetterModel(
        id: 3,
        letter: 'ي',
        letterAr: 'ياء المد',
        image: 'assets/images/level2/ya.png',
        sound: 'assets/sounds/letter_name/ya.mp3',
        wordText: 'بَيتْ',
        wordImage: 'assets/images/level2/house.png',
        wordLetters: const [
          WordLetterModel(
            letterId: 2,
            letter: 'بَ',
            image: 'assets/images/letters/2.png',
            sound: 'assets/sounds/letter_sound/ba.mp3',
          ),
          WordLetterModel(
            letterId: 28,
            letter: 'ي',
            image: 'assets/images/letters/28.png',
            sound: 'assets/sounds/letter_sound/ya.mp3',
            isMadLetter: true,
          ),
          WordLetterModel(
            letterId: 16,
            letter: 'تْ',
            image: 'assets/images/letters/3.png',
            sound: 'assets/sounds/letter_sound/ta.mp3',
          ),
        ],
      ),
    ];
  }
}