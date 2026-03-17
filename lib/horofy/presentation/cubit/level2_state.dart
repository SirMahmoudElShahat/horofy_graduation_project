import 'package:equatable/equatable.dart';
import 'package:horofy/horofy/domain/entities/mad_letter.dart';

enum Level2Step {
  letterImage,
  wordSpelled,
  wordFull,
  practiceSpelling,
  practiceWord,
  wordImage,
}

class Level2State extends Equatable {
  final List<MadLetter> madLetters;
  final int currentIndex;
  final Level2Step step;
  final bool isListening;
  final bool isCorrect;
  final String statusMessage;

  const Level2State({
    this.madLetters = const [],
    this.currentIndex = 0,
    this.step = Level2Step.letterImage,
    this.isListening = false,
    this.isCorrect = false,
    this.statusMessage = '',
  });

  MadLetter? get currentMadLetter =>
      madLetters.isEmpty ? null : madLetters[currentIndex];

  bool get isLastLetter => currentIndex >= madLetters.length - 1;

  Level2State copyWith({
    List<MadLetter>? madLetters,
    int? currentIndex,
    Level2Step? step,
    bool? isListening,
    bool? isCorrect,
    String? statusMessage,
  }) {
    return Level2State(
      madLetters: madLetters ?? this.madLetters,
      currentIndex: currentIndex ?? this.currentIndex,
      step: step ?? this.step,
      isListening: isListening ?? this.isListening,
      isCorrect: isCorrect ?? this.isCorrect,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  @override
  List<Object?> get props => [
    madLetters,
    currentIndex,
    step,
    isListening,
    isCorrect,
    statusMessage,
  ];
}

class Level2Initial extends Level2State {}

class Level2Loaded extends Level2State {
  const Level2Loaded({
    required super.madLetters,
    super.currentIndex,
    super.step,
    super.isListening,
    super.isCorrect,
    super.statusMessage,
  });

  @override
  Level2Loaded copyWith({
    List<MadLetter>? madLetters,
    int? currentIndex,
    Level2Step? step,
    bool? isListening,
    bool? isCorrect,
    String? statusMessage,
  }) {
    return Level2Loaded(
      madLetters: madLetters ?? this.madLetters,
      currentIndex: currentIndex ?? this.currentIndex,
      step: step ?? this.step,
      isListening: isListening ?? this.isListening,
      isCorrect: isCorrect ?? this.isCorrect,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
