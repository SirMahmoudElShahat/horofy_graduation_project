import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/horofy/data/datasources/letters_local_data_source.dart';
import 'package:horofy/horofy/data/models/letter_model.dart';
import 'package:horofy/horofy/presentation/cubit/progress_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/progress_state.dart';
import 'package:horofy/horofy/presentation/widgets/exercises_button.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Level1ListenScreen extends StatefulWidget {
  const Level1ListenScreen({super.key});

  @override
  State<Level1ListenScreen> createState() => _Level1ListenScreenState();
}

class _Level1ListenScreenState extends State<Level1ListenScreen> {
  final AudioPlayer player = AudioPlayer();
  final SpeechToText _speechToText = SpeechToText();
  List<LetterModel> _letters = [];
  int _currentIndex = 0;
  bool _speechEnabled = false;
  bool _isPracticeMode = false;
  String _statusMessage = '';
  int _childId = 0;

  String normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'[ًٌٍَُِّْـ]'), '')
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
    if (_childId != 0) {
      context.read<ProgressCubit>().loadProgress(_childId, 'level1');
    }
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      debugLogging: true,
      onStatus: (status) {
        if (status == "notListening") {
          setState(() {});
        }
      },
      onError: (error) {
        setState(() {
          _statusMessage = "حدث خطأ في التسجيل";
        });
      },
    );

    _statusMessage = _speechEnabled ? 'جاهز للاستماع' : 'الميكروفون غير متاح';
    setState(() {});
  }

  @override
  void dispose() {
    player.dispose();
    _speechToText.stop();
    super.dispose();
  }

  void _startListening() async {
    if (_speechToText.isListening) return;

    setState(() {
      _statusMessage = 'جاري الاستماع...';
    });

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
    setState(() {
      _statusMessage = 'تم الإيقاف';
    });
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    String spokenWords = normalizeArabic(result.recognizedWords);

    if (spokenWords.isEmpty) return;

    spokenWords = spokenWords
        .replaceAll("حرف", "")
        .replaceAll("الحرف", "")
        .trim();

    setState(() {
      _statusMessage = spokenWords.isEmpty
          ? 'لم يتم التقاط كلام'
          : 'جاري المعالجة...';
    });

    if (spokenWords.isEmpty) return;

    LetterModel currentLetter = _letters[_currentIndex];

    String correctLetter = normalizeArabic(currentLetter.letterAr);

    bool isCorrect =
        spokenWords.contains(correctLetter) ||
        spokenWords.contains(currentLetter.letterEn.toLowerCase());

    if (isCorrect) {
      setState(() {
        _statusMessage = 'إجابة صحيحة ✅';
      });
      if (_currentIndex < _letters.length - 1) {
        _showSnackBar(context, "أحسنت", "إجابة صحيحة!", isError: false);
        // Update progress for listened
        context.read<ProgressCubit>().markAsListened(
          _childId,
          'level1',
          currentLetter.id,
        );
        Navigator.pushNamed(
          context,
          exercisesResultScreen,
          arguments: () {
            Navigator.pushReplacementNamed(
              context,
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
        });
      } else {
        //await context.read<ChildCubit>().updateLevel(child!.id!, 'level1');
        _showSnackBar(context, "مبروك", "أنهيت جميع الحروف!", isError: false);
      }
    } else {
      setState(() {
        _statusMessage = 'خطأ — سمعت: $spokenWords';
      });
      _showSnackBar(context, "خطأ", "حاول مرة أخرى. سمعت: $spokenWords");
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
    if (_letters.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final currentLetter = _letters[_currentIndex];

    return BlocListener<ProgressCubit, ProgressState>(
      listener: (context, state) {
        if (state is ProgressLoaded) {
          // A letter is considered complete once it's written.
          final writtenLetterIds = state.progress
              .where((p) => p.written)
              .map((p) => p.letterId)
              .toSet();

          // Find the index of the first letter that has not been written.
          int nextIndex = _letters.indexWhere(
            (letter) => !writtenLetterIds.contains(letter.id),
          );

          // If all letters are written, `indexWhere` returns -1.
          // In that case, we can stay on the last letter.
          if (nextIndex == -1 && _letters.isNotEmpty) {
            nextIndex = _letters.length - 1;
          } else if (nextIndex == -1) {
            nextIndex = 0; // Handles case where _letters is empty
          }

          setState(() {
            _currentIndex = nextIndex;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            if (!_isPracticeMode)
              Positioned(
                top: 35,
                right: 25,
                child: ExercisesButton(
                  onPressed: () {
                    setState(() {
                      _isPracticeMode = true;
                    });
                  },
                  buttonIcon: Icons.arrow_forward_sharp,
                ),
              ),
            Positioned(child: Center(child: Image.asset(currentLetter.image))),
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
                              : (_speechEnabled ? _startListening : () {}))
                        : () async {
                            String soundPath = currentLetter.soundName;
                            if (soundPath.startsWith('assets/')) {
                              soundPath = soundPath.substring(7);
                            }
                            await player.stop();
                            await player.play(AssetSource(soundPath));
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
