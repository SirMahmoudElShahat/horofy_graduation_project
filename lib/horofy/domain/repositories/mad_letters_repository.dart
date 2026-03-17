import 'package:horofy/horofy/domain/entities/mad_letter.dart';

abstract class MadLettersRepository {
  List<MadLetter> getMadLetters();
}