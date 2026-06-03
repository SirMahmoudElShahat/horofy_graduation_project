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
import 'package:horofy/core/widgets/loading_overlay.dart';
import 'package:horofy/core/widgets/loading_widget.dart';
import 'package:horofy/horofy/data/datasources/letters_local_data_source.dart';
import 'package:horofy/horofy/data/models/letter_model.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/child_state.dart';
import 'package:horofy/horofy/presentation/cubit/submission_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/submission_state.dart';
import 'package:horofy/horofy/presentation/widgets/exercises_button.dart';
import 'package:horofy/core/services/ml_kit_model_service.dart';

class _Exercise {
  final int letterIndex;
  final String letter;
  final String target;
  final String? imagePath;
  final String? suffix;
  final bool isLastForLetter;

  const _Exercise({
    required this.letterIndex,
    required this.letter,
    required this.target,
    this.imagePath,
    this.suffix,
    required this.isLastForLetter,
  });
}

class Level5Screen extends StatefulWidget {
  const Level5Screen({super.key});

  @override
  State<Level5Screen> createState() => _Level5ScreenState();
}

class _Level5ScreenState extends State<Level5Screen> {
  // Build once from the shared data source — single source of truth
  static final List<LetterModel> _letters = LettersLocalDataSourceImpl()
      .getLetters();

  static final Map<String, LetterModel> _letterMap = {
    for (final l in _letters) l.letter: l,
  };

  static final List<_Exercise> _exercises = _buildExercises();

  static List<_Exercise> _buildExercises() {
    final list = <_Exercise>[];
    for (int i = 0; i < _letters.length; i++) {
      final letter = _letters[i].letter;
      if (letter == 'ب') {
        list.add(
          _Exercise(
            letterIndex: i,
            letter: letter,
            target: 'ب',
            isLastForLetter: false,
          ),
        );
        list.add(
          _Exercise(
            letterIndex: i,
            letter: letter,
            target: 'ب',
            imagePath: 'assets/images/level5/duck.png',
            suffix: 'طة',
            isLastForLetter: false,
          ),
        );
        list.add(
          _Exercise(
            letterIndex: i,
            letter: letter,
            target: 'بر',
            imagePath: 'assets/images/level5/orange.png',
            suffix: 'تقالة',
            isLastForLetter: true,
          ),
        );
      } else {
        list.add(
          _Exercise(
            letterIndex: i,
            letter: letter,
            target: letter,
            isLastForLetter: true,
          ),
        );
      }
    }
    return list;
  }

  final DigitalInkRecognizer _recognizer = DigitalInkRecognizer(
    languageCode: 'ar',
  );
  final AudioPlayer _player = AudioPlayer();

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

  int _exerciseIndex = 0;
  int _attemptsCount = 0;
  final List<String> _mistakes = [];
  DateTime _exerciseStartedAt = DateTime.now();

  bool _resumeApplied = false;

  _Exercise get _current => _exercises[_exerciseIndex];

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
      'level5',
      exerciseType: 'writing',
    );
    if (completed.isEmpty) return;

    // exerciseId = letterIndex + 1 — find first letter not yet submitted
    int firstIncomplete = -1;
    for (int i = 0; i < _letters.length; i++) {
      if (!completed.contains(i + 1)) {
        firstIncomplete = i;
        break;
      }
    }
    if (firstIncomplete == -1) return;

    final target = _exercises.indexWhere(
      (e) => e.letterIndex == firstIncomplete,
    );
    if (target > 0) {
      setState(() {
        _exerciseIndex = target;
        _attemptsCount = 0;
        _mistakes.clear();
        _exerciseStartedAt = DateTime.now();
      });
    }
  }

  @override
  void dispose() {
    _recognizer.close();
    _player.dispose();
    super.dispose();
  }

  Future<void> _playLetterSound() async {
    final model = _letterMap[_current.letter];
    if (model == null) return;
    // soundName is stored as "assets/sounds/…" — strip the "assets/" prefix for AssetSource
    final path = model.soundName.replaceFirst('assets/', '');
    await _player.stop();
    await _player.play(AssetSource(path));
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
        _mistakes.add(_current.target);
        _showError('لم يتم التعرف على الكتابة، حاول تاني');
        setState(() => _isProcessing = false);
        return;
      }

      final best = candidates.first.text;
      final normalizedBest = _normalize(best);
      final normalizedTarget = _normalize(_current.target);

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
        await _navigateOnCorrect();
      } else {
        _attemptsCount++;
        _mistakes.add(best);
        _showError('خطأ - كتبت: $best، المطلوب: ${_current.target}');
      }
    } catch (_) {
      setState(() => _isProcessing = false);
      _showError('حدث خطأ، حاول تاني');
    }
  }

  Future<void> _navigateOnCorrect() async {
    final navigator = Navigator.of(context);
    final childCubit = context.read<ChildCubit>();
    final ex = _current;
    final isLastExercise = _exerciseIndex == _exercises.length - 1;

    if (ex.isLastForLetter) {
      final duration = DateTime.now().difference(_exerciseStartedAt).inSeconds;

      if (_childId != 0) {
        // Fire and forget — same pattern as other levels
        context.read<SubmissionCubit>().submit(
          childId: _childId,
          level: 'level5',
          exerciseType: 'writing',
          exerciseId: ex.letterIndex + 1,
          status: 'pass',
          attemptsCount: _attemptsCount,
          duration: duration,
          totalItems: 1,
          mistakes: List.from(_mistakes),
          metadata: {'letter': ex.letter},
        );

        // Awaiting updateLevel triggers ChildUpdateLoading → LoadingOverlay
        if (isLastExercise) {
          await childCubit.updateLevel(_childId, 'level6');
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
          if (isLastExercise) {
            navigator.popUntil(ModalRoute.withName(childLevelsScreen));
          } else {
            navigator.pop();
            if (mounted) {
              _reset();
              setState(() => _exerciseIndex++);
            }
          }
        },
      );
    } else {
      Navigator.pushNamed(
        context,
        exercisesResultScreen,
        arguments: () {
          navigator.pop();
          if (mounted) {
            _reset();
            setState(() => _exerciseIndex++);
          }
        },
      );
    }
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
    final letterModel = _letterMap[_current.letter];

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
                  body: (!_isModelReady ||
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
                                !_current.isImageStep
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'اكتب حرف ال${letterModel?.letterAr ?? _current.letter}',
                                            style: AppTextStyles.blackFont
                                                .copyWith(fontSize: 35),
                                          ),
                                          const SizedBox(width: 16),
                                          ExercisesButton(
                                            onPressed: _playLetterSound,
                                            buttonIcon: Icons.headphones,
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                SizedBox(
                                  height: !_current.isImageStep ? 30 : 0,
                                ),
                                if (_current.isImageStep) ...[
                                  Image.asset(
                                    _current.imagePath!,
                                    height: 150,
                                    fit: BoxFit.contain,
                                    errorBuilder: (ctx, e, _) => const Icon(
                                      Icons.image_outlined,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                                SizedBox(
                                  height: 110,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        textDirection: TextDirection.rtl,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          _buildWritingArea(),
                                          if (_current.suffix != null)
                                            Text(
                                              _current.suffix!,
                                              style: AppTextStyles.blackFont
                                                  .copyWith(
                                                    fontSize: 48,
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                        ],
                                      ),
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
            ),
          );
        },
      );
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingWidget(),
          SizedBox(height: 20),
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

  Widget _buildWritingArea() {
    final narrow = _current.suffix != null;
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
            width: narrow ? 130 : 280,
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

extension on _Exercise {
  bool get isImageStep => imagePath != null;
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
