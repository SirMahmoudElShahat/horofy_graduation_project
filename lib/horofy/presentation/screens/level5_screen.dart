import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart'
    hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart'
    as ml_ink
    show Ink;
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/widgets/exercises_button.dart';

// ── Step enum ─────────────────────────────────────────────────────────────────
enum _Level5Step {
  writeBa, // Step 1: write ب alone
  writeBaDuck, // Step 2: write ب next to بطه image (suffix: طه)
  writeBrOrange, // Step 3: write بر next to برتقالة image (suffix: تقالة)
}

class Level5Screen extends StatefulWidget {
  const Level5Screen({super.key});

  @override
  State<Level5Screen> createState() => _Level5ScreenState();
}

class _Level5ScreenState extends State<Level5Screen> {
  // ── ML Kit ────────────────────────────────────────────────
  final DigitalInkRecognizer _recognizer = DigitalInkRecognizer(
    languageCode: 'ar',
  );
  final ModelManager _modelManager = DigitalInkRecognizerModelManager();

  // ── Audio ─────────────────────────────────────────────────
  final AudioPlayer _player = AudioPlayer();

  // ── Drawing ───────────────────────────────────────────────
  final ml_ink.Ink _ink = ml_ink.Ink();
  List<StrokePoint> _currentStroke = [];
  final List<List<Offset>> _offsetStrokes = [];
  List<Offset> _currentOffsetStroke = [];

  // ── State ─────────────────────────────────────────────────
  bool _hasStrokes = false;
  bool _isProcessing = false;
  String _recognizedText = '';
  bool _showResult = false;
  bool? _isCorrectMatch;
  int _childId = 0;
  bool _isModelReady = false;

  _Level5Step _step = _Level5Step.writeBa;

  // ── Target words per step ─────────────────────────────────
  static const _targets = {
    _Level5Step.writeBa: 'ب',
    _Level5Step.writeBaDuck: 'ب',
    _Level5Step.writeBrOrange: 'بر',
  };

  String get _currentTarget => _targets[_step]!;

  @override
  void initState() {
    super.initState();
    _downloadModelIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _childId =
        (ModalRoute.of(context)?.settings.arguments as Map?)?['childId'] ?? 0;
  }

  Future<void> _downloadModelIfNeeded() async {
    final isDownloaded = await _modelManager.isModelDownloaded('ar');
    if (!isDownloaded) {
      await _modelManager.downloadModel('ar');
    }
    // warm-up
    try {
      final dummyInk = ml_ink.Ink();
      dummyInk.strokes.add(
        Stroke()
          ..points.addAll([
            StrokePoint(x: 0, y: 0, t: 0),
            StrokePoint(x: 1, y: 1, t: 1),
          ]),
      );
      await _recognizer.recognize(dummyInk);
    } catch (_) {}

    if (mounted) setState(() => _isModelReady = true);
  }

  @override
  void dispose() {
    _recognizer.close();
    _player.dispose();
    super.dispose();
  }

  // ── Play Ba sound ─────────────────────────────────────────
  Future<void> _playBaSound() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/letter_name/ba.mp3'));
  }

  // ── Normalize ─────────────────────────────────────────────
  String _normalize(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'[ًٌٍَُِّْـ]'), '')
        .trim();
  }

  // ── Pointer Events ────────────────────────────────────────
  void _onPointerDown(PointerDownEvent e, RenderBox box) {
    if (_showResult) {
      _ink.strokes.clear();
      _offsetStrokes.clear();
      _showResult = false;
      _recognizedText = '';
      _isCorrectMatch = null;
    }
    _currentStroke = [];
    _currentOffsetStroke = [];
    final local = box.globalToLocal(e.position);
    _addPoint(e.timeStamp, local);
  }

  void _onPointerMove(PointerMoveEvent e, RenderBox box) {
    final local = box.globalToLocal(e.position);
    _addPoint(e.timeStamp, local);
  }

  void _onPointerUp(PointerUpEvent e, RenderBox box) {
    final local = box.globalToLocal(e.position);
    _addPoint(e.timeStamp, local);
    _ink.strokes.add(Stroke()..points.addAll(_currentStroke));
    setState(() {
      _offsetStrokes.add(List.from(_currentOffsetStroke));
      _hasStrokes = true;
      _showResult = false;
      _recognizedText = '';
      _isCorrectMatch = null;
    });
  }

  void _addPoint(Duration timestamp, Offset local) {
    final t = timestamp.inMilliseconds;
    _currentStroke.add(StrokePoint(x: local.dx, y: local.dy, t: t));
    _currentOffsetStroke.add(local);
    setState(() {});
  }

  // ── Reset drawing only ────────────────────────────────────
  void _reset() {
    setState(() {
      _ink.strokes.clear();
      _offsetStrokes.clear();
      _currentStroke = [];
      _currentOffsetStroke = [];
      _hasStrokes = false;
      _recognizedText = '';
      _showResult = false;
      _isProcessing = false;
      _isCorrectMatch = null;
    });
  }

  // ── Recognize and handle per-step logic ───────────────────
  Future<void> _recognize() async {
    if (_ink.strokes.isEmpty || _isProcessing || _isCorrectMatch == true)
      return;

    setState(() => _isProcessing = true);

    try {
      final candidates = await _recognizer.recognize(_ink);

      if (candidates.isEmpty) {
        _showError('لم يتم التعرف على الكتابة، حاول تاني');
        setState(() => _isProcessing = false);
        return;
      }

      final best = candidates.first.text;
      final normalizedBest = _normalize(best);
      final normalizedTarget = _normalize(_currentTarget);

      final isCorrect = normalizedTarget.length <= 2
          ? normalizedBest.replaceAll(' ', '') == normalizedTarget
          : (normalizedBest.contains(normalizedTarget) ||
                normalizedTarget.contains(normalizedBest) ||
                _levenshtein(normalizedBest, normalizedTarget) <= 1);

      setState(() {
        _recognizedText = best;
        _showResult = true;
        _isProcessing = false;
        _isCorrectMatch = isCorrect;
      });

      if (isCorrect) {
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;
        _navigateOnCorrect();
      } else {
        _showError('خطأ — كتبت: $best، المطلوب: $_currentTarget');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError('حدث خطأ، حاول تاني');
    }
  }

  // ── Navigate based on current step ───────────────────────
  void _navigateOnCorrect() {
    final navigator = Navigator.of(context);
    final cubit = context.read<ChildCubit>();

    switch (_step) {
      // Step 1 done → result screen → come back to step 2 (duck)
      case _Level5Step.writeBa:
        Navigator.pushNamed(
          context,
          exercisesResultScreen,
          arguments: () {
            navigator.pop();
            if (mounted) {
              _reset();
              setState(() => _step = _Level5Step.writeBaDuck);
            }
          },
        );
        break;

      // Step 2 done → result screen → come back to step 3 (orange)
      case _Level5Step.writeBaDuck:
        Navigator.pushNamed(
          context,
          exercisesResultScreen,
          arguments: () {
            navigator.pop();
            if (mounted) {
              _reset();
              setState(() => _step = _Level5Step.writeBrOrange);
            }
          },
        );
        break;

      // Step 3 done → upgrade level → result screen → back to levels
      case _Level5Step.writeBrOrange:
        Navigator.pushNamed(
          context,
          exercisesResultScreen,
          arguments: () async {
            if (_childId != 0) {
              await cubit.updateLevel(_childId, 'level6');
            }
            navigator.popUntil(ModalRoute.withName(childLevelsScreen));
          },
        );
        break;
    }
  }

  // ── Levenshtein distance for fuzzy match ─────────────────
  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    final matrix = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => j == 0 ? i : (i == 0 ? j : 0)),
    );
    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        matrix[i][j] = a[i - 1] == b[j - 1]
            ? matrix[i - 1][j - 1]
            : 1 +
                  [
                    matrix[i - 1][j],
                    matrix[i][j - 1],
                    matrix[i - 1][j - 1],
                  ].reduce(min);
      }
    }
    return matrix[a.length][b.length];
  }

  void _showError(String msg) {
    Get.snackbar(
      'خطأ',
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: !_isModelReady
          ? _buildLoadingView()
          : SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Header row: title + headphone ────────────
                        _step == _Level5Step.writeBa
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _headerText(),
                                    style: AppTextStyles.blackFont.copyWith(
                                      fontSize: 35,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ExercisesButton(
                                    onPressed: _playBaSound,
                                    buttonIcon: Icons.headphones,
                                  ),
                                ],
                              )
                            : SizedBox(),
                        SizedBox(height: _step == _Level5Step.writeBa ? 30 : 0),
                        // ── Image + suffix label (steps 2 & 3) ───────
                        if (_step != _Level5Step.writeBa) ...[
                          Image.asset(
                            _stepImagePath(),
                            height: 150,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ── Writing area row ──────────────────────────
                        SizedBox(
                          height: 110,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                textDirection: TextDirection
                                    .rtl, // لضمان وضع حرف الـ ب يمين الكلمة دائماً
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildWritingArea(),
                                  if (_step != _Level5Step.writeBa)
                                    Text(
                                      _stepSuffix(),
                                      style: AppTextStyles.blackFont.copyWith(
                                        fontSize: 48,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // Send / draw button
                              _isProcessing
                                  ? const SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : ExercisesButton(
                                      buttonIcon: _hasStrokes
                                          ? Icons.send_rounded
                                          : Icons.draw,
                                      onPressed:
                                          (_hasStrokes &&
                                              _isCorrectMatch != true)
                                          ? _recognize
                                          : () {},
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Reset button (top left) ───────────────────────
                  if (_hasStrokes)
                    Positioned(
                      top: 20,
                      left: 20,
                      child: ExercisesButton(
                        buttonIcon: Icons.refresh,
                        onPressed: _reset,
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  /// ── Loading view while model is being prepared ─────────────────
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 20),
          Text(
            '...جاري التحضير',
            style: TextStyle(
              fontFamily: 'Cairo-ExtraBold',
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Header text per step ──────────────────────────────────
  String _headerText() {
    switch (_step) {
      case _Level5Step.writeBa:
        return 'اكتب حرف الباء';
      case _Level5Step.writeBaDuck:
        return '';
      case _Level5Step.writeBrOrange:
        return '';
    }
  }

  // ── Image path per step ───────────────────────────────────
  String _stepImagePath() {
    switch (_step) {
      case _Level5Step.writeBaDuck:
        return 'assets/images/level5/duck.png';
      case _Level5Step.writeBrOrange:
        return 'assets/images/level5/orange.png';
      default:
        return '';
    }
  }

  // ── Suffix text shown next to writing area ────────────────
  String _stepSuffix() {
    switch (_step) {
      case _Level5Step.writeBaDuck:
        return 'طه';
      case _Level5Step.writeBrOrange:
        return 'تقالة';
      default:
        return '';
    }
  }

  // ── Writing Area ──────────────────────────────────────────
  Widget _buildWritingArea() {
    return Builder(
      builder: (ctx) {
        return Listener(
          onPointerDown: (e) {
            final box = ctx.findRenderObject() as RenderBox?;
            if (box != null) _onPointerDown(e, box);
          },
          onPointerMove: (e) {
            final box = ctx.findRenderObject() as RenderBox?;
            if (box != null) _onPointerMove(e, box);
          },
          onPointerUp: (e) {
            final box = ctx.findRenderObject() as RenderBox?;
            if (box != null) _onPointerUp(e, box);
          },
          child: Container(
            width: _step == _Level5Step.writeBa
                ? 280
                : 130, // تصغير المربع في حال إكمال الكلمة
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                painter: _WritingPainter(
                  strokes: _offsetStrokes,
                  currentStroke: _currentOffsetStroke,
                  recognizedText: _showResult ? _recognizedText : '',
                  isCorrectMatch: _isCorrectMatch,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
//  Writing Painter
// ============================================================
class _WritingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final String recognizedText;
  final bool? isCorrectMatch;

  _WritingPainter({
    required this.strokes,
    required this.currentStroke,
    required this.recognizedText,
    this.isCorrectMatch,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Dotted baseline ───────────────────────────────────
    if ((strokes.isEmpty && currentStroke.isEmpty) ||
        recognizedText.isNotEmpty) {
      _drawDottedLine(canvas, size);
    }

    // ── Recognized text centered in area ─────────────────
    if (recognizedText.isNotEmpty) {
      Color textColor = AppColors.primary;
      if (isCorrectMatch == true) textColor = Colors.green;
      if (isCorrectMatch == false) textColor = Colors.redAccent;

      final tp = TextPainter(
        text: TextSpan(
          text: recognizedText,
          style: TextStyle(
            fontFamily: 'Cairo-ExtraBold',
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        textDirection: TextDirection.rtl,
      );
      tp.layout(maxWidth: size.width);
      tp.paint(
        canvas,
        Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
      );
    } else {
      // ── Draw ink strokes ─────────────────────────────
      final strokePaint = Paint()
        ..color = AppColors.primary.withOpacity(0.85)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (final stroke in strokes) {
        _drawStroke(canvas, stroke, strokePaint);
      }
      _drawStroke(canvas, currentStroke, strokePaint);
    }
  }

  void _drawDottedLine(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.25)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dotSpacing = 12.0;
    final y = size.height / 2;
    double x = 10;
    while (x < size.width - 10) {
      canvas.drawCircle(Offset(x, y), 2, dotPaint);
      x += dotSpacing;
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WritingPainter old) => true;
}
