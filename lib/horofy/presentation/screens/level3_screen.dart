import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/widgets/exercises_button.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

// ══════════════════════════════════════════════════════════
//  بيانات الحروف — كلمة "لعب"
// ══════════════════════════════════════════════════════════
class _LetterData {
  final String letter;
  final String image;
  final String sound;

  const _LetterData({
    required this.letter,
    required this.image,
    required this.sound,
  });
}

const _wordLetters = [
  _LetterData(
    letter: 'ل',
    image: 'assets/images/letters/23.png',
    sound: 'assets/sounds/letter_sound/lam.mp3',
  ),
  _LetterData(
    letter: 'ع',
    image: 'assets/images/letters/18.png',
    sound: 'assets/sounds/letter_sound/ayn.mp3',
  ),
  _LetterData(
    letter: 'ب',
    image: 'assets/images/letters/2.png',
    sound: 'assets/sounds/letter_sound/ba.mp3',
  ),
];

const _wordText = 'لَعِب';
const _wordImagePath = 'assets/images/level3/play.png';

// ══════════════════════════════════════════════════════════
//  Steps
// ══════════════════════════════════════════════════════════
enum _Level3Step {
  letters, // خطوة 1: الحروف واحد واحد
  record, // خطوة 2: تسجيل الكلمة
  wordImage, // خطوة 3: صورة الكلمة
}

// ══════════════════════════════════════════════════════════
//  Screen
// ══════════════════════════════════════════════════════════
class Level3Screen extends StatefulWidget {
  const Level3Screen({super.key});

  @override
  State<Level3Screen> createState() => _Level3ScreenState();
}

class _Level3ScreenState extends State<Level3Screen> {
  final AudioPlayer _player = AudioPlayer();
  final SpeechToText _stt = SpeechToText();

  _Level3Step _step = _Level3Step.letters;

  // خطوة التسجيل
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isCorrect = false;
  String _statusMessage = '';

  int _childId = 0;

  // ── init ────────────────────────────────────────────────
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
      onError: (_) => setState(() => _isListening = false),
      onStatus: (s) {
        if (s == 'notListening' && mounted)
          setState(() => _isListening = false);
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _player.dispose();
    _stt.stop();
    super.dispose();
  }

  // ── helpers ─────────────────────────────────────────────
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

  Future<void> _playAsset(String path) async {
    final p = path.startsWith('assets/') ? path.substring(7) : path;
    await _player.stop();
    await _player.play(AssetSource(p));
  }

  // ── navigation ───────────────────────────────────────────
  void _onNext() {
    switch (_step) {
      case _Level3Step.letters:
        setState(() {
          _step = _Level3Step.record;
          _statusMessage = '';
          _isCorrect = false;
        });
        break;

      case _Level3Step.record:
        setState(() => _step = _Level3Step.wordImage);
        break;

      case _Level3Step.wordImage:
        _finishLevel();
        break;
    }
  }

  Future<void> _finishLevel() async {
    // رفع المستوى للـ level4
    if (_childId != 0) {
      await context.read<ChildCubit>().updateLevel(_childId, 'level4');
    }

    if (!mounted) return;

    final navigator = Navigator.of(context);
    Navigator.pushNamed(
      context,
      exercisesResultScreen,
      arguments: () {
        // نرجع لصفحة الـ childHomeScreen وننظف الـ stack
        navigator.popUntil(ModalRoute.withName(childLevelsScreen));
      },
    );
  }

  // ── speech ───────────────────────────────────────────────
  Future<void> _startListening() async {
    if (_isListening || !_speechEnabled) return;
    setState(() {
      _isListening = true;
      _isCorrect = false;
      _statusMessage = '';
    });
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
    setState(() => _isListening = false);
  }

  void _onResult(SpeechRecognitionResult result) {
    String spoken = _normalize(
      result.recognizedWords,
    ).replaceAll('حرف', '').replaceAll('الحرف', '').trim();

    if (spoken.isEmpty) return;

    // نقارن بكلمة "لعب" بعد تنميط
    final correct = _normalize(_wordText); // لعب
    final isCorrect =
        spoken.contains(correct) ||
        spoken.contains('لعب') ||
        spoken.contains('لاعب');

    setState(() {
      _isListening = false;
      _isCorrect = isCorrect;
      _statusMessage = isCorrect ? 'ممتاز! ✅' : 'حاول تاني 🔄  سمعت: $spoken';
    });
  }

  // ══════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // ── المحتوى ──────────────────────────────────
            _buildStepContent(),

            // ── زرار Next ─────────────────────────────────
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  // ── Next button ──────────────────────────────────────────
  Widget _buildNextButton() {
    // نخبي الزرار لو في خطوة التسجيل والإجابة غلط
    final hide = _step == _Level3Step.record && !_isCorrect;

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
            onPressed: _onNext,
          ),
        ),
      ),
    );
  }

  // ── Step router ──────────────────────────────────────────
  Widget _buildStepContent() {
    switch (_step) {
      case _Level3Step.letters:
        return _buildLettersStep();
      case _Level3Step.record:
        return _buildRecordStep();
      case _Level3Step.wordImage:
        return _buildWordImageStep();
    }
  }

  // ══════════════════════════════════════════════════════════
  //  STEP 1 — الحروف واحد واحد
  // ══════════════════════════════════════════════════════════
  Widget _buildLettersStep() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'استمع للحروف 🔊',
            style: AppTextStyles.greyFont.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),

          // التلت حروف جمب بعض بترتيب الكلمة (RTL)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _wordLetters.reversed.map((wl) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // صورة الحرف
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(wl.image, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // الحرف مكتوب
                    Text(
                      wl.letter,
                      style: AppTextStyles.blackFont.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // زرار السماعة
                    ExercisesButton(
                      buttonIcon: Icons.headphones_rounded,
                      onPressed: () => _playAsset(wl.sound),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  STEP 2 — تسجيل الكلمة
  // ══════════════════════════════════════════════════════════
  Widget _buildRecordStep() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'انطق الكلمة 🎤',
            style: AppTextStyles.greyFont.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // الكلمة مكتوبة كبيرة
          Text(
            _wordText,
            style: AppTextStyles.blackFont.copyWith(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),

          // زرار الميكروفون
          Stack(
            alignment: Alignment.center,
            children: [
              if (_isListening)
                const SizedBox(
                  width: 70,
                  height: 70,
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
          const SizedBox(height: 24),

          // رسالة النتيجة
          if (_statusMessage.isNotEmpty)
            AnimatedOpacity(
              opacity: _statusMessage.isNotEmpty ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
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
                  style: AppTextStyles.blackFont.copyWith(
                    fontSize: 16,
                    color: _isCorrect ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  STEP 3 — صورة الكلمة
  // ══════════════════════════════════════════════════════════
  Widget _buildWordImageStep() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _wordText,
            style: AppTextStyles.blackFont.copyWith(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Image.asset(
            _wordImagePath,
            height: 220,
            fit: BoxFit.contain,
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
        ],
      ),
    );
  }
}
