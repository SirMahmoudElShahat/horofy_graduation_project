import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/horofy/domain/entities/progress_entity.dart';
import 'package:horofy/horofy/domain/usecases/mad_letters_usecase.dart';
import 'package:horofy/horofy/domain/usecases/progress_usecases.dart';
import 'level2_state.dart';

class Level2Cubit extends Cubit<Level2State> {
  final GetMadLettersUseCase getMadLettersUseCase;
  final SaveProgressUseCase saveProgressUseCase;
  final GetProgressForChildUseCase getProgressForChildUseCase;
  final GetProgressForLetterUseCase getProgressForLetterUseCase;
  final UpdateProgressUseCase updateProgressUseCase;

  Level2Cubit({
    required this.getMadLettersUseCase,
    required this.saveProgressUseCase,
    required this.getProgressForChildUseCase,
    required this.getProgressForLetterUseCase,
    required this.updateProgressUseCase,
  }) : super(Level2Initial());

  // ── Load Data ────────────────────────────────────────
  void loadMadLetters() {
    final letters = getMadLettersUseCase();
    emit(Level2Loaded(madLetters: letters, step: Level2Step.letterImage));
  }

  // ── Next Step ─────────────────────────────────
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

  // ── Speech Result ─────────────────────────────────
  void onSpeechResult({required bool isCorrect, required String spokenText}) {
    final s = state;
    if (s is! Level2Loaded) return;

    // If spokenText is empty → reset without message
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

  // ── Save Progress & Next Letter ─────────────────────
  Future<void> saveProgressAndNext({required int childId}) async {
    final s = state;
    if (s is! Level2Loaded) return;

    final letter = s.currentMadLetter;
    if (letter == null) return;

    await _saveProgress(childId: childId, letterId: letter.id);

    if (s.isLastLetter) return; // The screen will handle the end

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

  // ── Load Child Progress for Current Level ─────────────────────
  Future<void> loadProgress(int childId) async {
    final s = state;
    if (s is! Level2Loaded) return;

    try {
      final progress = await getProgressForChildUseCase(childId, 'level2');
      final doneLetterIds = progress
          .where((p) => p.listened || p.spoken || p.written)
          .map((p) => p.letterId)
          .toSet();

      final nextIndex = s.madLetters.indexWhere((l) => !doneLetterIds.contains(l.id));
      final resolvedIndex =
          nextIndex == -1 ? (s.madLetters.isNotEmpty ? s.madLetters.length - 1 : 0) : nextIndex;

      emit(
        s.copyWith(
          currentIndex: resolvedIndex,
          step: Level2Step.letterImage,
          isListening: false,
          isCorrect: false,
          statusMessage: '',
        ),
      );
    } catch (_) {
      // ignore errors
    }
  }

  // ── Save Progress in DB ────────────────────────────────
  Future<void> _saveProgress({
    required int childId,
    required int letterId,
  }) async {
    try {
      var existing = await getProgressForLetterUseCase(
        childId,
        'level2',
        letterId,
      );

      if (existing == null) {
        await saveProgressUseCase(
          ProgressEntity(
            childId: childId,
            level: 'level2',
            letterId: letterId,
            listened: true,
            spoken: true,
          ),
        );
      } else {
        await updateProgressUseCase(
          ProgressEntity(
            id: existing.id,
            childId: existing.childId,
            level: existing.level,
            letterId: existing.letterId,
            listened: true,
            spoken: true,
            written: existing.written,
          ),
        );
      }
    } catch (_) {}
  }
}
