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
import 'package:horofy/core/widgets/loading_overlay.dart';
import 'package:horofy/core/widgets/loading_widget.dart';
import 'package:horofy/horofy/data/datasources/letters_local_data_source.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/child_state.dart';
import 'package:horofy/horofy/presentation/cubit/submission_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/submission_state.dart';
import 'package:horofy/horofy/presentation/widgets/exercises_button.dart';
import 'package:horofy/core/services/ml_kit_model_service.dart';

class _WordData {
  final int letterIndex;
  final String word;
  final String imagePath;

  const _WordData({
    required this.letterIndex,
    required this.word,
    required this.imagePath,
  });
}

class Level7Screen extends StatefulWidget {
  const Level7Screen({super.key});

  @override
  State<Level7Screen> createState() => _Level7ScreenState();
}

class _Level7ScreenState extends State<Level7Screen> {
  static const _wordTexts = [
    'أرنب', // ا
    'برتقالة', // ب
    'تفاحة', // ت
    'ثلج', // ث
    'جزر', // ج
    'حذاء', // ح
    'خضار', // خ
    'دب', // د
    'ذرة', // ذ
    'رمان', // ر
    'زهرة', // ز
    'سمكة', // س
    'شمس', // ش
    'صندوق', // ص
    'ضرس', // ض
    'طماطم', // ط
    'ظرف', // ظ
    'عصفورة', // ع
    'غيوم', // غ
    'فجل', // ف
    'قلم', // ق
    'كتاب', // ك
    'لمون', // ل
    'منطاد', // م
    'نحلة', // ن
    'هرة', // ه
    'ورق', // و
    'يد', // ي
  ];

  static final List<_WordData> _words = _buildWords();

  static List<_WordData> _buildWords() {
    final letters = LettersLocalDataSourceImpl().getLetters();
    return List.generate(
      letters.length,
      (i) => _WordData(
        letterIndex: i,
        word: _wordTexts[i],
        imagePath: letters[i].image,
      ),
    );
  }

  final DigitalInkRecognizer _recognizer = DigitalInkRecognizer(
    languageCode: 'ar',
  );

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

  int _wordIndex = 0;
  int _attemptsCount = 0;
  final List<String> _mistakes = [];
  DateTime _exerciseStartedAt = DateTime.now();

  bool _resumeApplied = false;

  _WordData get _current => _words[_wordIndex];

  @override
  void initState() {
    super.initState();
    // Model is already ready from app startup — just reflect that in state
    if (MlKitModelService.instance.isReady) {
      _isModelReady = true;
    } else {
      // Fallback: wait if somehow called before main() finished
      MlKitModelService.instance.ensureReady('ar').then((_) {
        if (mounted) setState(() => _isModelReady = true);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newChildId =
        (ModalRoute.of(context)?.settings.arguments as Map?)?['childId'] ?? 0;
    if (newChildId != _childId) _childId = newChildId;
    if (_childId != 0 && !_resumeApplied) {
      context.read<SubmissionCubit>().loadChildSubmissions(_childId);
    }
  }

  void _applyResume(SubmissionsLoaded state) {
    if (_resumeApplied) return;
    _resumeApplied = true;

    final completed = state.completedExerciseIds(
      'level7',
      exerciseType: 'writing',
    );
    if (completed.isEmpty) return;

    // exerciseId = letterIndex + 1 — find first word not yet submitted
    int firstIncomplete = -1;
    for (int i = 0; i < _words.length; i++) {
      if (!completed.contains(i + 1)) {
        firstIncomplete = i;
        break;
      }
    }
    if (firstIncomplete > 0) {
      setState(() {
        _wordIndex = firstIncomplete;
        _attemptsCount = 0;
        _mistakes.clear();
        _exerciseStartedAt = DateTime.now();
      });
    }
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
        _mistakes.add(_current.word);
        _showError('لم يتم التعرف على الكتابة، حاول تاني');
        setState(() => _isProcessing = false);
        return;
      }

      final best = candidates.first.text;
      final normRec = _normalize(best).replaceAll(' ', '');
      final normTar = _normalize(_current.word);
      final maxLen = normTar.isNotEmpty ? normTar.length : 1;

      // Primary accuracy check (mirrors Python Levenshtein accuracy formula)
      int dist = _levenshtein(normRec, normTar);
      double accuracy = (maxLen - dist) / maxLen * 100;
      bool dysgraphiaAlarm = false;
      bool usedFlipped = false;

      if (accuracy < 80) {
        final flippedText = await _recognizeFlipped();
        if (flippedText != null) {
          final normFlipped = _normalize(flippedText).replaceAll(' ', '');
          final distFlip = _levenshtein(normFlipped, normTar);
          final accuracyFlip = (maxLen - distFlip) / maxLen * 100;
          if (accuracyFlip > accuracy) {
            accuracy = accuracyFlip;
            dysgraphiaAlarm = true;
            usedFlipped = true;
          }
        }
      }

      // Also catch exact reverse of target (e.g. wrote "قيرطب" instead of "بطريق")
      final reversedTarget = normTar.split('').reversed.join();
      if (!dysgraphiaAlarm && normRec == reversedTarget && normRec != normTar) {
        dysgraphiaAlarm = true;
      }

      final isCorrect = accuracy >= 80.0;

      setState(() {
        _recognizedText = isCorrect && dysgraphiaAlarm && usedFlipped
            ? _current.word
            : best;
        _showResult = true;
        _isProcessing = false;
        _isCorrectMatch = isCorrect;
      });

      if (isCorrect) {
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;
        await _onCorrect();
      } else {
        _attemptsCount++;
        _mistakes.add(best);
        if (dysgraphiaAlarm) {
          _showError('الكتابة معكوسة! حاول تكتب من اليمين لليسار');
        } else {
          _showError('خطأ - كتبت: $best، المطلوب: ${_current.word}');
        }
      }
    } catch (_) {
      setState(() => _isProcessing = false);
      _showError('حدث خطأ، حاول تاني');
    }
  }

  /// Mirrors all ink strokes horizontally and runs recognition on the result.
  /// Returns the top candidate text, or null if recognition fails.
  Future<String?> _recognizeFlipped() async {
    if (_ink.strokes.isEmpty) return null;

    double maxX = 0;
    for (final stroke in _ink.strokes) {
      for (final point in stroke.points) {
        if (point.x > maxX) {
          maxX = point.x;
        }
      }
    }

    final flippedInk = ml_ink.Ink();
    for (final stroke in _ink.strokes) {
      final flippedStroke = Stroke();
      for (final point in stroke.points) {
        flippedStroke.points.add(
          StrokePoint(x: maxX - point.x, y: point.y, t: point.t),
        );
      }
      flippedInk.strokes.add(flippedStroke);
    }

    try {
      final candidates = await _recognizer.recognize(flippedInk);
      return candidates.isNotEmpty ? candidates.first.text : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _onCorrect() async {
    final navigator = Navigator.of(context);
    final childCubit = context.read<ChildCubit>();
    final duration = DateTime.now().difference(_exerciseStartedAt).inSeconds;
    final isLast = _wordIndex == _words.length - 1;

    if (_childId != 0) {
      context.read<SubmissionCubit>().submit(
        childId: _childId,
        level: 'level7',
        exerciseType: 'writing',
        exerciseId: _current.letterIndex + 1,
        status: 'pass',
        attemptsCount: _attemptsCount,
        duration: duration,
        totalItems: 1,
        mistakes: List.from(_mistakes),
        metadata: {'word': _current.word},
      );

      if (isLast) {
        await childCubit.updateLevel(_childId, 'level7');
      }
    }

    _attemptsCount = 0;
    _mistakes.clear();
    _exerciseStartedAt = DateTime.now();

    if (!mounted) return;

    Navigator.pushNamed(
      context,
      exercisesResultScreen,
      arguments: () {
        if (isLast) {
          navigator.popUntil(ModalRoute.withName(childLevelsScreen));
        } else {
          navigator.pop();
          if (mounted) {
            _reset();
            setState(() => _wordIndex++);
          }
        }
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubmissionCubit, SubmissionState>(
      listener: (context, state) {
        if (state is SubmissionsLoaded) {
          _applyResume(state);
        } else if (state is SubmissionLoading) {
          // Even if loading, mark resume as pending so UI doesn't hang
          // Resume will complete when SubmissionsLoaded arrives
        }
      },
      child: BlocBuilder<SubmissionCubit, SubmissionState>(
        builder: (context, submissionState) {
          return BlocBuilder<ChildCubit, ChildState>(
            builder: (context, childState) {
              return LoadingOverlay(
                isLoading: childState is ChildUpdateLoading,
                child: Scaffold(
                  backgroundColor: AppColors.background,
                  body:
                      (!_isModelReady ||
                          (_childId != 0 &&
                              !_resumeApplied &&
                              submissionState is! SubmissionsLoaded))
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
                                      _current.imagePath,
                                      width: 200,
                                      height: 200,
                                      errorBuilder: (ctx, e, _) => const Icon(
                                        Icons.image_outlined,
                                        size: 100,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 110,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          _buildWritingArea(),
                                          const SizedBox(width: 16),
                                          _isProcessing
                                              ? const SizedBox(
                                                  width: 50,
                                                  height: 50,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color:
                                                            AppColors.primary,
                                                        strokeWidth: 3,
                                                      ),
                                                )
                                              : ExercisesButton(
                                                  buttonIcon: _hasStrokes
                                                      ? Icons.send_rounded
                                                      : Icons.draw,
                                                  onPressed:
                                                      (_hasStrokes &&
                                                          _isCorrectMatch !=
                                                              true)
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
                ),
              );
            },
          );
        },
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
