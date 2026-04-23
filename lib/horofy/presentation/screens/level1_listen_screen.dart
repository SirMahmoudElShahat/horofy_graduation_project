import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/horofy/data/datasources/letters_local_data_source.dart';
import 'package:horofy/horofy/data/models/letter_model.dart';
import 'package:horofy/horofy/presentation/cubit/submission_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/submission_state.dart';
import 'package:horofy/horofy/presentation/widgets/exercises_button.dart';
import 'package:horofy/core/widgets/loading_overlay.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Level1ListenScreen extends StatefulWidget {
  const Level1ListenScreen({super.key});

  @override
  State<Level1ListenScreen> createState() => _Level1ListenScreenState();
}

class _Level1ListenScreenState extends State<Level1ListenScreen> {
  final AudioPlayer _player = AudioPlayer();
  final SpeechToText _speechToText = SpeechToText();

  List<LetterModel> _letters = [];
  int _currentIndex = 0;
  bool _speechEnabled = false;
  bool _isPracticeMode = false;
  int _childId = 0;

  int _attemptsCount = 0;
  final List<String> _currentMistakes = [];
  DateTime _exerciseStartedAt = DateTime.now();

  bool _resumeApplied = false;

  String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'[ًٌٍَُِّْـ]'), '')
        .trim()
        .toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    _letters = LettersLocalDataSourceImpl().getLetters();
    _initSpeech();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _childId =
        (ModalRoute.of(context)?.settings.arguments as Map?)?['childId'] ?? 0;

    if (_childId != 0 && !_resumeApplied) {
      context.read<SubmissionCubit>().loadChildSubmissions(_childId);
    }
  }

  void _applyResume(SubmissionsLoaded state) {
    if (_resumeApplied || _letters.isEmpty) return;
    _resumeApplied = true;

    final completed = state.completedExerciseIds(
      'level1',
      exerciseType: 'writing',
    );
    if (completed.isEmpty) return;

    final nextIndex = _letters.indexWhere((l) => !completed.contains(l.id));
    setState(() {
      _currentIndex = nextIndex == -1 ? _letters.length - 1 : nextIndex;
      _exerciseStartedAt = DateTime.now();
    });
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      debugLogging: true,
      onStatus: (s) {
        if (s == 'notListening' && mounted) setState(() {});
      },
      onError: (_) {
        if (mounted) setState(() {});
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _player.dispose();
    _speechToText.stop();
    super.dispose();
  }

  void _startListening() async {
    if (_speechToText.isListening) return;
    setState(() {});
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 4),
      localeId: 'ar-SA',
      listenMode: ListenMode.dictation,
    );
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    String spoken = _normalizeArabic(result.recognizedWords);
    if (spoken.isEmpty) return;

    spoken = spoken.replaceAll('حرف', '').replaceAll('الحرف', '').trim();
    if (spoken.isEmpty) return;

    final currentLetter = _letters[_currentIndex];
    final correctLetter = _normalizeArabic(currentLetter.letterAr);

    final isCorrect =
        spoken.contains(correctLetter) ||
        spoken.contains(currentLetter.letterEn.toLowerCase());

    if (isCorrect) {
      final duration = DateTime.now().difference(_exerciseStartedAt).inSeconds;

      if (_childId != 0) {
        context.read<SubmissionCubit>().submit(
          childId: _childId,
          level: 'level1',
          exerciseType: 'listening',
          exerciseId: currentLetter.id,
          status: 'pass',
          attemptsCount: _attemptsCount,
          duration: duration,
          totalItems: _letters.length,
          mistakes: List.from(_currentMistakes),
          metadata: {
            'letterAr': currentLetter.letterAr,
            'letterEn': currentLetter.letterEn,
          },
        );
      }

      _showSnackBar(context, 'أحسنت', 'إجابة صحيحة!', isError: false);

      final navigator = Navigator.of(context);
      Navigator.pushNamed(
        context,
        exercisesResultScreen,
        arguments: () {
          navigator.pushReplacementNamed(
            level1WriteScreen,
            arguments: {
              'letter': currentLetter.letter,
              'childId': _childId,
              'letterId': currentLetter.id,
            },
          );
        },
      );

      setState(() {
        _currentIndex++;
        _isPracticeMode = false;
        _attemptsCount = 0;
        _currentMistakes.clear();
        _exerciseStartedAt = DateTime.now();
      });
    } else if (result.finalResult) {
      _attemptsCount++;
      _currentMistakes.add(spoken);
      _showSnackBar(context, 'خطأ', 'حاول مرة أخرى. سمعت: $spoken');
    }
  }

  void _showSnackBar(
    BuildContext context,
    String title,
    String message, {
    bool isError = true,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: isError ? SnackPosition.TOP : SnackPosition.BOTTOM,
      backgroundColor: isError
          ? Colors.redAccent.withOpacity(0.9)
          : Colors.green.withOpacity(0.9),
      colorText: Theme.of(context).cardColor,
      icon: Icon(
        isError ? Icons.warning_amber_rounded : Icons.check_circle_outline,
        color: Theme.of(context).cardColor,
      ),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubmissionCubit, SubmissionState>(
      listener: (context, state) {
        if (state is SubmissionsLoaded) _applyResume(state);
      },
      child: BlocBuilder<SubmissionCubit, SubmissionState>(
        builder: (context, state) {
          final isLoading =
              state is SubmissionLoading ||
              state is SubmissionInitial ||
              state is SubmissionSending;

          if (_letters.isEmpty && !isLoading) {
            return const Scaffold(body: Center(child: Text('لا توجد بيانات')));
          }

          final currentLetter = _letters.isNotEmpty
              ? _letters[_currentIndex]
              : null;

          return LoadingOverlay(
            isLoading: isLoading,
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: currentLetter == null
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        if (!_isPracticeMode)
                          Positioned(
                            top: 35,
                            right: 25,
                            child: ExercisesButton(
                              onPressed: () =>
                                  setState(() => _isPracticeMode = true),
                              buttonIcon: Icons.arrow_forward_sharp,
                            ),
                          ),
                        Positioned(
                          child: Center(
                            child: Image.asset(currentLetter.image),
                          ),
                        ),
                        Positioned(
                          bottom: 30,
                          left: 25,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_isPracticeMode && _speechToText.isListening)
                                const SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 3,
                                  ),
                                ),
                              ExercisesButton(
                                buttonIcon: _isPracticeMode
                                    ? (_speechToText.isListening
                                          ? Icons.stop_rounded
                                          : Icons.mic)
                                    : Icons.headphones_rounded,
                                onPressed: _isPracticeMode
                                    ? (_speechToText.isListening
                                          ? _stopListening
                                          : (_speechEnabled
                                                ? _startListening
                                                : () {}))
                                    : () async {
                                        String soundPath =
                                            currentLetter.soundName;
                                        if (soundPath.startsWith('assets/')) {
                                          soundPath = soundPath.substring(7);
                                        }
                                        await _player.stop();
                                        await _player.play(
                                          AssetSource(soundPath),
                                        );
                                      },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
