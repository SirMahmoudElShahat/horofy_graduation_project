import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/horofy/domain/usecases/mad_letters_usecase.dart';
import 'level2_state.dart';

class Level2Cubit extends Cubit<Level2State> {
  final GetMadLettersUseCase getMadLettersUseCase;

  Level2Cubit({required this.getMadLettersUseCase}) : super(Level2Initial());

  // ── Load Data ────────────────────────────────────────
  void loadMadLetters() {
    final letters = getMadLettersUseCase();
    emit(Level2Loaded(madLetters: letters, step: Level2Step.letterImage));
  }

  // ── Next Step ─────────────────────────────────────────
  void nextStep() {
    final s = state;
    if (s is! Level2Loaded) return;
    final nextStep = _getNextStep(s.step);
    emit(s.copyWith(step: nextStep, statusMessage: '', isCorrect: false));
  }

  Level2Step _getNextStep(Level2Step current) {
    switch (current) {
      case Level2Step.letterImage:
        return Level2Step.wordSpelled;
      case Level2Step.wordSpelled:
        return Level2Step.wordFull;
      case Level2Step.wordFull:
        return Level2Step.practiceSpelling;
      case Level2Step.practiceSpelling:
        return Level2Step.practiceWord;
      case Level2Step.practiceWord:
        return Level2Step.wordImage;
      case Level2Step.wordImage:
        return Level2Step.letterImage;
    }
  }

  // ── Update Mic Status ─────────────────────────────────
  void setListening(bool value) {
    final s = state;
    if (s is! Level2Loaded) return;
    emit(s.copyWith(isListening: value));
  }

  // ── Speech Result ─────────────────────────────────────
  void onSpeechResult({required bool isCorrect, required String spokenText}) {
    final s = state;
    if (s is! Level2Loaded) return;

    if (spokenText.isEmpty) {
      emit(s.copyWith(isCorrect: false, isListening: false, statusMessage: ''));
      return;
    }

    emit(
      s.copyWith(
        isCorrect: isCorrect,
        isListening: false,
        statusMessage: isCorrect
            ? 'ممتاز! ✅'
            : 'حاول تاني 🔄  سمعت: $spokenText',
      ),
    );
  }

  // ── Move to Next Letter ───────────────────────────────
  void moveToNextLetter() {
    final s = state;
    if (s is! Level2Loaded) return;
    if (s.isLastLetter) return;

    emit(
      s.copyWith(
        currentIndex: s.currentIndex + 1,
        step: Level2Step.letterImage,
        isListening: false,
        isCorrect: false,
        statusMessage: '',
      ),
    );
  }

  // ── Jump to specific index (used for resume on re-entry) ──────────────────
  void jumpToIndex(int index) {
    final s = state;
    if (s is! Level2Loaded) return;
    if (index < 0 || index >= s.madLetters.length) return;

    emit(
      s.copyWith(
        currentIndex: index,
        step: Level2Step.letterImage,
        isListening: false,
        isCorrect: false,
        statusMessage: '',
      ),
    );
  }
}