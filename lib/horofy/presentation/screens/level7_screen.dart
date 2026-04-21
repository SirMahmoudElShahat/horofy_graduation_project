import 'dart:math';
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
import 'package:horofy/core/widgets/loading_widget.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/submission_cubit.dart';
import 'package:horofy/horofy/presentation/widgets/exercises_button.dart';

class Level7Screen extends StatefulWidget {
  const Level7Screen({super.key});

  @override
  State<Level7Screen> createState() => _Level7ScreenState();
}

class _Level7ScreenState extends State<Level7Screen> {
  final DigitalInkRecognizer _recognizer = DigitalInkRecognizer(
    languageCode: 'ar',
  );
  final ModelManager _modelManager = DigitalInkRecognizerModelManager();

  final ml_ink.Ink _ink = ml_ink.Ink();
  List<StrokePoint> _currentStroke = [];
  final List<List<Offset>> _offsetStrokes = [];
  List<Offset> _currentOffsetStroke = [];

  bool _hasStrokes = false;
  bool _isProcessing = false;
  String _recognizedText = '';
  bool _showResult = false;
  bool? _isCorrectMatch;
  int _childId = 0;
  bool _isModelReady = false;
  int _attemptsCount = 0;
  final List<String> _mistakes = [];
  DateTime _exerciseStartedAt = DateTime.now();

  static const String _targetWord = 'بطريق';

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
    if (!isDownloaded) await _modelManager.downloadModel('ar');
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
    super.dispose();
  }

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
    _addPoint(e.timeStamp, box.globalToLocal(e.position));
  }

  void _onPointerUp(PointerUpEvent e, RenderBox box) {
    _addPoint(e.timeStamp, box.globalToLocal(e.position));
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

  Future<void> _recognize() async {
    if (_ink.strokes.isEmpty || _isProcessing || _isCorrectMatch == true) {
      return;
    }
    setState(() => _isProcessing = true);

    try {
      final candidates = await _recognizer.recognize(_ink);
      if (candidates.isEmpty) {
        _attemptsCount++;
        _mistakes.add(_targetWord);
        _showError('لم يتم التعرف على الكتابة، حاول تاني');
        setState(() => _isProcessing = false);
        return;
      }

      final best = candidates.first.text;
      final normalizedBest = _normalize(best);
      final normalizedTarget = _normalize(_targetWord);

      final isCorrect =
          normalizedBest.contains(normalizedTarget) ||
              normalizedTarget.contains(normalizedBest) ||
              _levenshtein(normalizedBest, normalizedTarget) <= 1;

      setState(() {
        _recognizedText = best;
        _showResult = true;
        _isProcessing = false;
        _isCorrectMatch = isCorrect;
      });

      if (isCorrect) {
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;

        if (_childId != 0) {
          final duration = DateTime.now().difference(_exerciseStartedAt).inSeconds;
          context.read<SubmissionCubit>().submit(
            childId: _childId,
            level: 'level7',
            exerciseType: 'writing',
            exerciseId: 1,
            status: 'pass',
            attemptsCount: _attemptsCount,
            duration: duration,
            totalItems: 1,
            mistakes: List.from(_mistakes),
            metadata: {'word': _targetWord},
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
      } else {
        _attemptsCount++;
        _mistakes.add(best);
        _showError('خطأ - كتبت: $best، المطلوب: $_targetWord');
      }
    } catch (_) {
      setState(() => _isProcessing = false);
      _showError('حدث خطأ، حاول تاني');
    }
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    final matrix = List.generate(
      a.length + 1,
      (i) => List.generate(
        b.length + 1,
        (j) => j == 0 ? i : (i == 0 ? j : 0),
      ),
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
                        Image.asset(
                          'assets/images/level7/batrek.png',
                          width: 200,
                          height: 200,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_outlined,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 110,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildWritingArea(),
                              const SizedBox(width: 16),
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

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LoadingWidget(),
          const SizedBox(height: 20),
          Text(
            '...جاري التحضير',
            style: const TextStyle(
              fontFamily: 'Cairo-ExtraBold',
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

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
            width: 280,
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
    if ((strokes.isEmpty && currentStroke.isEmpty) ||
        recognizedText.isNotEmpty) {
      _drawDottedLine(canvas, size);
    }

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
