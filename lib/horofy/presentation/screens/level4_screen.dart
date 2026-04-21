import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/submission_cubit.dart';
import 'package:horofy/horofy/presentation/widgets/exercises_button.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class _WordData {
  final String word;
  final String imagePath;
  final String targetLetter;

  const _WordData({
    required this.word,
    required this.imagePath,
    required this.targetLetter,
  });
}

const _words = [
  _WordData(
    word: 'بَيْت',
    imagePath: 'assets/images/level4/home.png',
    targetLetter: 'ب',
  ),
  _WordData(
    word: 'بَقَرة',
    imagePath: 'assets/images/level4/cow.png',
    targetLetter: 'ب',
  ),
];

const _correctChoice = 'ب';
const _baSound = 'sounds/letter_name/ba.mp3';

enum _Level4Step { choose, record }

class Level4Screen extends StatefulWidget {
  const Level4Screen({super.key});

  @override
  State<Level4Screen> createState() => _Level4ScreenState();
}

class _Level4ScreenState extends State<Level4Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final AudioPlayer _player = AudioPlayer();
  final SpeechToText _stt = SpeechToText();

  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isCorrect = false;
  String _statusMessage = '';

  int _wordIndex = 0;
  _Level4Step _step = _Level4Step.choose;
  int _childId = 0;

  int _attemptsCount = 0;
  final List<String> _mistakes = [];
  DateTime _exerciseStartedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
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
    _controller.dispose();
    _player.dispose();
    _stt.stop();
    super.dispose();
  }

  Future<void> _playSound(String assetPath) async {
    await _player.stop();
    await _player.play(AssetSource(assetPath));
  }

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

  void _showSnackBar(String title, String message, {bool isError = true}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
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

  void _onLetterTap(String letter) {
    if (letter == _correctChoice) {
      final navigator = Navigator.of(context);
      Navigator.pushNamed(
        context,
        exercisesResultScreen,
        arguments: () {
          navigator.pop();
          if (mounted) {
            setState(() {
              _step = _Level4Step.record;
              _isCorrect = false;
              _statusMessage = '';
            });
          }
        },
      );
    } else {
      _attemptsCount++;
      _mistakes.add(letter);
      _showSnackBar('خطأ', 'حاول تاني! الإجابة الصحيحة هي حرف الباء ب');
    }
  }

  Future<void> _startListening() async {
    if (_isListening || !_speechEnabled) return;
    setState(() {
      _isListening = true;
      _isCorrect = false;
      _statusMessage = '';
    });
    await _stt.listen(
      onResult: _onSpeechResult,
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

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted || _isCorrect) return;

    String spoken = _normalize(result.recognizedWords)
        .replaceAll('حرف', '')
        .replaceAll('الحرف', '')
        .trim();
    if (spoken.isEmpty) return;

    bool isCorrect = false;
    if (_wordIndex == 0) {
      isCorrect = spoken.contains('بيت') || spoken.contains('بيتا');
    } else {
      isCorrect = spoken.contains('بقره') ||
          spoken.contains('بقرة') ||
          spoken.contains('بقر');
    }

    if (!isCorrect && result.finalResult) {
      _attemptsCount++;
      _mistakes.add(spoken);
    }

    setState(() {
      _isCorrect = isCorrect;
      _statusMessage =
          isCorrect ? 'ممتاز! ✅' : 'حاول تاني 🔄  سمعت: $spoken';
    });

    if (isCorrect) {
      _stt.stop();
      setState(() => _isListening = false);
      _showSnackBar('أحسنت', 'إجابة صحيحة!', isError: false);
      _navigateOnCorrect();
    }
  }

  void _navigateOnCorrect() {
    final isLastWord = _wordIndex == _words.length - 1;
    final navigator = Navigator.of(context);
    final childCubit = context.read<ChildCubit>();
    final submissionCubit = context.read<SubmissionCubit>();

    if (!isLastWord) {
      Navigator.pushNamed(
        context,
        exercisesResultScreen,
        arguments: () {
          navigator.pop();
          if (mounted) {
            setState(() {
              _wordIndex = 1;
              _step = _Level4Step.record;
              _isCorrect = false;
              _statusMessage = '';
            });
          }
        },
      );
      return;
    }

    Navigator.pushNamed(
      context,
      exercisesResultScreen,
      arguments: () async {
        if (_childId != 0) {
          final duration = DateTime.now().difference(_exerciseStartedAt).inSeconds;
          submissionCubit.submit(
            childId: _childId,
            level: 'level4',
            exerciseType: 'listening',
            exerciseId: 1,
            status: 'pass',
            attemptsCount: _attemptsCount,
            duration: duration,
            totalItems: _words.length,
            mistakes: List.from(_mistakes),
            metadata: {
              'targetLetter': _correctChoice,
              'words': _words.map((word) => word.word).toList(),
            },
          );
          await childCubit.updateLevel(_childId, 'level5');
        }
        navigator.popUntil(ModalRoute.withName(childLevelsScreen));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _step == _Level4Step.choose
          ? _buildChooseStep()
          : _buildRecordStep(),
    );
  }

  Widget _buildChooseStep() {
    return Stack(
      children: [
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'أختر حرف (الباء) ؟',
                    style: AppTextStyles.blackFont.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ExercisesButton(
                    onPressed: () => _playSound(_baSound),
                    buttonIcon: Icons.headphones,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 100,
                children: [
                  GestureDetector(
                    onTap: () => _onLetterTap('ق'),
                    child: Text(
                      'ق',
                      style: AppTextStyles.whiteFont.copyWith(
                        fontFamily: 'Cairo-ExtraBold',
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _onLetterTap('ب'),
                    child: Text(
                      'ب',
                      style: AppTextStyles.whiteFont.copyWith(
                        fontFamily: 'Cairo-ExtraBold',
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _onLetterTap('ر'),
                    child: Text(
                      'ر',
                      style: AppTextStyles.whiteFont.copyWith(
                        fontFamily: 'Cairo-ExtraBold',
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordStep() {
    final word = _words[_wordIndex];
    return Stack(
      children: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildColoredWord(word),
              const SizedBox(width: 60),
              Image.asset(
                word.imagePath,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_outlined, size: 100, color: Colors.grey),
              ),
            ],
          ),
        ),
        if (_statusMessage.isNotEmpty)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _isCorrect
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isCorrect
                          ? Colors.green.withOpacity(0.4)
                          : Colors.red.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      fontFamily: 'Cairo-ExtraBold',
                      fontSize: 16,
                      color: _isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          ),
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
                buttonIcon: _isListening ? Icons.stop_rounded : Icons.mic,
                onPressed: _isListening ? _stopListening : _startListening,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColoredWord(_WordData word) {
    final chars = word.word.characters.toList();
    return Text.rich(
      TextSpan(
        children: chars.map((char) {
          final bare = char.replaceAll(RegExp(r'[ًٌٍَُِّْـ]'), '');
          final isTarget = bare == word.targetLetter;
          return TextSpan(
            text: char,
            style: TextStyle(
              fontFamily: 'Cairo-ExtraBold',
              fontSize: 100,
              fontWeight: FontWeight.bold,
              color: isTarget ? Colors.blue : AppColors.primary,
            ),
          );
        }).toList(),
      ),
    );
  }
}
