import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/widgets/loading_overlay.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/child_state.dart';
import 'package:horofy/horofy/presentation/cubit/submission_cubit.dart';
import 'package:horofy/horofy/presentation/widgets/exercises_button.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

const _words = ['أنا', 'أحب', 'البطيخ'];

class Level6Screen extends StatefulWidget {
  const Level6Screen({super.key});

  @override
  State<Level6Screen> createState() => _Level6ScreenState();
}

class _Level6ScreenState extends State<Level6Screen> {
  final SpeechToText _stt = SpeechToText();

  bool _speechEnabled = false;
  bool _isListening = false;
  int _confirmedCount = 0;
  int _childId = 0;
  int _attemptsCount = 0;
  final List<String> _mistakes = [];
  DateTime _exerciseStartedAt = DateTime.now();

  bool get _allDone => _confirmedCount >= _words.length;

  String get _targetSentence =>
      _words.sublist(0, _confirmedCount + 1).join(' ');

  String _normalize(String text) {
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
    _initStt();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _childId =
        (ModalRoute.of(context)?.settings.arguments as Map?)?['childId'] ?? 0;
  }

  Future<void> _initStt() async {
    _speechEnabled = await _stt.initialize(
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
      onStatus: (s) {
        if (s == 'notListening' && mounted) {
          setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _stt.stop();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (_isListening || !_speechEnabled || _allDone) return;
    setState(() => _isListening = true);
    await _stt.listen(
      onResult: _onResult,
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 4),
      localeId: 'ar-SA',
      listenMode: ListenMode.dictation,
    );
  }

  Future<void> _stopListening() async {
    await _stt.stop();
    if (mounted) setState(() => _isListening = false);
  }

  void _onResult(SpeechRecognitionResult result) {
    if (!mounted || _allDone) return;

    final spoken = _normalize(result.recognizedWords).trim();
    if (spoken.isEmpty) return;

    final targetWords = _normalize(_targetSentence).split(' ');
    final isCorrect = targetWords.every((w) => spoken.contains(w));

    if (isCorrect) {
      _stt.stop();
      setState(() {
        _isListening = false;
        _confirmedCount++;
      });
      Get.closeAllSnackbars();
      _showSnackBar(
        'أحسنت 🎉',
        'صح!',
        isError: false,
        position: _allDone ? SnackPosition.BOTTOM : SnackPosition.TOP,
      );
    } else if (result.finalResult) {
      setState(() => _isListening = false);
      _attemptsCount++;
      _mistakes.add(_targetSentence);
      _showSnackBar('حاول تاني 🔄', 'سمعت: $spoken');
    }
  }

  Future<void> _onNext() async {
    if (_childId != 0) {
      final duration = DateTime.now().difference(_exerciseStartedAt).inSeconds;
      context.read<SubmissionCubit>().submit(
        childId: _childId,
        level: 'level6',
        exerciseType: 'listening',
        exerciseId: 1,
        status: 'pass',
        attemptsCount: _attemptsCount,
        duration: duration,
        totalItems: _words.length,
        mistakes: List.from(_mistakes),
        metadata: {'sentence': _words.join(' ')},
      );
      await context.read<ChildCubit>().updateLevel(_childId, 'level7');
    }
    if (!mounted) return;
    final navigator = Navigator.of(context);
    Navigator.pushNamed(
      context,
      exercisesResultScreen,
      arguments: () {
        navigator.popUntil(ModalRoute.withName(childLevelsScreen));
      },
    );
  }

  void _showSnackBar(
    String title,
    String message, {
    bool isError = true,
    SnackPosition position = SnackPosition.TOP,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: isError
          ? Colors.redAccent.withOpacity(0.9)
          : Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      icon: Icon(
        isError ? Icons.warning_amber_rounded : Icons.check_circle_outline,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildCubit, ChildState>(
      builder: (context, childState) {
        return LoadingOverlay(
          isLoading: childState is ChildUpdateLoading,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Stack(
                children: [
                  _allDone ? _buildSuccessView() : _buildSentenceView(),
                  if (_allDone)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: ExercisesButton(
                        buttonIcon: Icons.arrow_forward_sharp,
                        onPressed: _onNext,
                      ),
                    ),
                  if (!_allDone)
                    Positioned(
                      bottom: 30,
                      left: 25,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isListening)
                            const SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 3,
                              ),
                            ),
                          ExercisesButton(
                            buttonIcon: _isListening
                                ? Icons.stop_rounded
                                : Icons.mic,
                            onPressed: _isListening
                                ? _stopListening
                                : _startListening,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSentenceView() {
    final visibleCount = _confirmedCount + 1;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(visibleCount, (i) {
          final isConfirmed = i < _confirmedCount;
          final isCurrent = i == _confirmedCount;

          return AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontFamily: 'Cairo-ExtraBold',
              fontWeight: FontWeight.bold,
              fontSize: isCurrent ? 68 : 54,
              color: isConfirmed ? Colors.green : AppColors.primary,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isConfirmed)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 26,
                      ),
                    ),
                  Text(_words[i]),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'أنا أحب البطيخ 🎉',
            style: TextStyle(
              fontFamily: 'Cairo-ExtraBold',
              fontWeight: FontWeight.bold,
              fontSize: 36,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 32),
          Image.asset(
            'assets/images/level6/watermelon.png',
            height: 220,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.emoji_food_beverage,
              size: 120,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
