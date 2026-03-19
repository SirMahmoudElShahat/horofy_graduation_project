import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/domain/entities/mad_letter.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/level2_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/level2_state.dart';
import 'package:horofy/horofy/presentation/widgets/exercises_button.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Level2Screen extends StatefulWidget {
  const Level2Screen({super.key});

  @override
  State<Level2Screen> createState() => _Level2ScreenState();
}

class _Level2ScreenState extends State<Level2Screen> {
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();

  bool _speechEnabled = false;
  int _childId = 0;
  bool _progressLoaded = false;

  // ── helpers ──────────────────────────────────────────────
  String normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ك', 'ق')
        .replaceAll(RegExp(r'[ًٌٍَُِّْـ]'), '')
        .trim()
        .toLowerCase();
  }

  // ── init ─────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initTts();
    _initStt();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _childId =
        (ModalRoute.of(context)?.settings.arguments as Map?)?['childId'] ?? 0;
    _tryLoadProgress();
  }

  void _tryLoadProgress() {
    if (_progressLoaded || _childId == 0) return;

    final state = context.read<Level2Cubit>().state;
    if (state is! Level2Loaded) return;

    _progressLoaded = true;
    context.read<Level2Cubit>().loadProgress(_childId);
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ar-SA');
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.0);
  }

  Future<void> _initStt() async {
    _speechEnabled = await _stt.initialize(
      onError: (_) => setState(() {}),
      onStatus: (s) {
        if (s == 'notListening') setState(() {});
      },
    );
    setState(() {});
  }

  @override
  void dispose() {
    _player.dispose();
    _tts.stop();
    _stt.stop();
    super.dispose();
  }

  // ── audio helpers ─────────────────────────────────────────
  Future<void> _playAsset(String path) async {
    String p = path.startsWith('assets/') ? path.substring(7) : path;
    await _player.stop();
    await _player.play(AssetSource(p));
  }

  Future<void> _speakWord(String word) async {
    await _tts.stop();
    await _tts.speak(word);
  }

  // ── speech ────────────────────────────────────────────────
  Future<void> _startListening(MadLetter letter) async {
    if (_stt.isListening) return;

    // امسح النتيجة القديمة عشان الطفل يحاول تاني بدون confusion
    context.read<Level2Cubit>().onSpeechResult(
      isCorrect: false,
      spokenText: '',
    );

    context.read<Level2Cubit>().setListening(true);

    await _stt.listen(
      onResult: (r) => _onResult(r, letter),
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 4),
      localeId: 'ar-SA',
      listenMode: ListenMode.dictation,
    );
  }

  Future<void> _stopListening() async {
    await _stt.stop();
    context.read<Level2Cubit>().setListening(false);
  }

  void _onResult(SpeechRecognitionResult result, MadLetter letter) {
    String spoken = normalizeArabic(
      result.recognizedWords,
    ).replaceAll('حرف', '').replaceAll('الحرف', '').trim();

    if (spoken.isEmpty) return;

    final currentStep =
        (context.read<Level2Cubit>().state as Level2Loaded).step;

    bool isCorrect;

    if (currentStep == Level2Step.practiceSpelling) {
      // يتحقق من حرف المد بس
      final madWordLetter = letter.wordLetters.firstWhere(
        (wl) => wl.isMadLetter,
      );
      final correct = normalizeArabic(madWordLetter.letter);
      final letterAr = normalizeArabic(letter.letterAr);
      isCorrect = spoken.contains(correct) || spoken.contains(letterAr);
    } else {
      // practiceWord — يتحقق من الكلمة كاملة
      final correctWord = normalizeArabic(letter.wordText);
      isCorrect = spoken.contains(correctWord);
    }

    context.read<Level2Cubit>().onSpeechResult(
      isCorrect: isCorrect,
      spokenText: spoken,
    );

    if (isCorrect) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _speakWord(letter.wordText);
      });
    }
  }

  // ── next handler ──────────────────────────────────────────
  Future<void> _onNext(Level2Loaded state) async {
    if (state.step == Level2Step.wordImage) {
      await context.read<Level2Cubit>().saveProgressAndNext(childId: _childId);

      if (!mounted) return;

      final isLast = state.isLastLetter;

      // لو ده آخر حرف، نحدث مستوى الطفل لـ level3
      if (isLast && _childId != 0) {
        await context.read<ChildCubit>().updateLevel(_childId, 'level3');
      }

      if (!mounted) return;
      final navigator = Navigator.of(context);
      Navigator.pushNamed(
        context,
        exercisesResultScreen,
        arguments: () {
          if (isLast) {
            Navigator.popUntil(context, ModalRoute.withName(childHomeScreen));
          } else {
            navigator.pop(); 
          }
        },
      );
      return;
    }

    if (state.step == Level2Step.wordSpelled) {
      await _speakWord(state.currentMadLetter!.wordText);
    }

    context.read<Level2Cubit>().nextStep();
  }

  // ══════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return BlocListener<Level2Cubit, Level2State>(
      listener: (_, state) {
        if (state is Level2Loaded) {
          _tryLoadProgress();
        }
      },
      child: BlocBuilder<Level2Cubit, Level2State>(
        builder: (context, state) {
          if (state is! Level2Loaded || state.currentMadLetter == null) {
            return const Scaffold(
              backgroundColor: Color(0xFFFAEFE4),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final letter = state.currentMadLetter!;

          return Scaffold(
            backgroundColor: const Color(0xFFFAEFE4),
            body: SafeArea(
              child: Stack(
                children: [
                  // ── المحتوى ─────────────────────────────────
                  _buildStepContent(state, letter),

                  // ── زر Next ─────────────────────────────────
                  _buildNextButton(state, letter),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Next button ───────────────────────────────────────────
  Widget _buildNextButton(Level2Loaded state, MadLetter letter) {
    final hide =
        (state.step == Level2Step.practiceSpelling && !state.isCorrect) ||
        (state.step == Level2Step.practiceWord && !state.isCorrect);

    return Positioned(
      top: 20,
      right: 20,
      child: AnimatedOpacity(
        opacity: hide ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: hide,
          child: ExercisesButton(
            buttonIcon: Icons.arrow_forward_sharp,
            onPressed: () => _onNext(state),
          ),
        ),
      ),
    );
  }

  // ── Step Router ───────────────────────────────────────────
  Widget _buildStepContent(Level2Loaded state, MadLetter letter) {
    switch (state.step) {
      case Level2Step.letterImage:
        return _buildLetterImage(letter);
      case Level2Step.wordSpelled:
        return _buildWordSpelled(letter);
      case Level2Step.wordFull:
        return _buildWordFull(state, letter);
      case Level2Step.practiceSpelling:
        return _buildPracticeSpelling(state, letter);
      case Level2Step.practiceWord: 
        return _buildPracticeWord(state, letter);
      case Level2Step.wordImage:
        return _buildWordImage(letter);
    }
  }

  // ══════════════════════════════════════════════════════════
  //  STEP 1 — صورة حرف المد
  // ══════════════════════════════════════════════════════════
  Widget _buildLetterImage(MadLetter letter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // اسم الحرف
          Text(
            letter.letterAr,
            style: AppTextStyles.greyFont.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // صورة الحرف
          Image.asset(letter.image, height: 250, fit: BoxFit.contain),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  STEP 2 — الكلمة مفصلة
  // ══════════════════════════════════════════════════════════
  Widget _buildWordSpelled(MadLetter letter) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'الكلمة مفصلة',
            style: AppTextStyles.greyFont.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // RTL → نعكس الترتيب عشان العربي يبدأ من اليمين
            children: letter.wordLetters.reversed
                .map((wl) => _buildSpelledLetterCard(wl))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpelledLetterCard(WordLetter wl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // صورة الحرف
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: wl.isMadLetter
                  ? AppColors.primary.withOpacity(0.12)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: wl.isMadLetter
                    ? AppColors.primary
                    : Colors.grey.shade300,
                width: wl.isMadLetter ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(wl.image, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 6),
          // الحرف مكتوب
          Text(
            wl.letter,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: wl.isMadLetter ? AppColors.primary : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          // زرار الصوت
          ExercisesButton(
            buttonIcon: Icons.volume_up_rounded,
            onPressed: () => _playAsset(wl.sound),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  STEP 3 — الكلمة على بعضها + TTS
  // ══════════════════════════════════════════════════════════
  Widget _buildWordFull(Level2Loaded state, MadLetter letter) {
    // normalize بدون diacritics للمقارنة بس
    String stripDiacritics(String s) =>
        s.replaceAll(RegExp(r'[ًٌٍَُِّْـ]'), '');

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'الكلمة كاملة',
            style: AppTextStyles.greyFont.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              children: letter.wordText.split('').map((char) {
                final isMadLetter =
                    stripDiacritics(char) == stripDiacritics(letter.letter);
                return TextSpan(
                  text: char,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: isMadLetter
                        ? Colors
                              .orange // ← لون مختلف لحرف المد
                        : const Color(0xFF774019),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
          ExercisesButton(
            buttonIcon: Icons.volume_up_rounded,
            onPressed: () => _speakWord(letter.wordText),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  STEP 4 — تسجيل حرف المد
  // ══════════════════════════════════════════════════════════
  Widget _buildPracticeSpelling(Level2Loaded state, MadLetter letter) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'انطق حرف المد 🎤',
            style: AppTextStyles.greyFont.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // الحروف مع المايك تحت حرف المد
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: letter.wordLetters.reversed.map((wl) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // صورة
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: wl.isMadLetter
                            ? AppColors.primary.withOpacity(0.12)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: wl.isMadLetter
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          width: wl.isMadLetter ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(wl.image, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // الحرف
                    Text(
                      wl.letter,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: wl.isMadLetter
                            ? AppColors.primary
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // مايك تحت حرف المد فقط
                    if (wl.isMadLetter)
                      _buildMicButton(state, letter)
                    else
                      const SizedBox(height: 50),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // status message
          if (state.statusMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: state.isCorrect
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                state.statusMessage,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  color: state.isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMicButton(Level2Loaded state, MadLetter letter) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (state.isListening)
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
        ExercisesButton(
          buttonIcon: state.isListening ? Icons.stop_rounded : Icons.mic,
          onPressed: state.isListening
              ? _stopListening
              : (_speechEnabled ? () => _startListening(letter) : () {}),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  //  STEP 5 — تسجيل الكلمة كاملة
  // ══════════════════════════════════════════════════════════
  Widget _buildPracticeWord(Level2Loaded state, MadLetter letter) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'انطق الكلمة كاملة 🎤',
            style: AppTextStyles.greyFont.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // الكلمة مكتوبة كبيرة
          Text(
            letter.wordText,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Color(0xFF774019),
            ),
          ),
          const SizedBox(height: 32),

          // زرار المايك
          _buildMicButton(state, letter),
          const SizedBox(height: 24),

          // status message
          if (state.statusMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: state.isCorrect
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                state.statusMessage,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  color: state.isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  STEP 6 — صورة الكلمة
  // ══════════════════════════════════════════════════════════
  Widget _buildWordImage(MadLetter letter) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            letter.wordText,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF774019),
            ),
          ),
          const SizedBox(height: 20),
          Image.asset(
            letter.wordImage,
            height: 220,
            fit: BoxFit.contain,
            // لو الصورة مش موجودة بعد → placeholder
            errorBuilder: (_, __, ___) => Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Icon(Icons.image_outlined, size: 80, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
