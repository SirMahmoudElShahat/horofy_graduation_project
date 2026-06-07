import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/widgets/loading_overlay.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/child_state.dart';
import 'package:horofy/horofy/presentation/cubit/submission_cubit.dart';

// ============================================================
//  LetterPixelMap
// ============================================================
class LetterPixelMap {
  final Uint8List _alpha;
  final int width;
  final int height;

  LetterPixelMap._(this._alpha, this.width, this.height);

  static Future<LetterPixelMap> build(
    String letter,
    double canvasWidth,
    double canvasHeight,
  ) async {
    final w = canvasWidth.toInt();
    final h = canvasHeight.toInt();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, canvasWidth, canvasHeight),
    );

    final fontSize = canvasWidth * 0.65;
    final tp = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.black,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
      textDirection: TextDirection.rtl,
    );
    tp.layout(maxWidth: canvasWidth);
    final offsetX = (canvasWidth - tp.width) / 2;
    final offsetY = (canvasHeight - tp.height) / 2;
    tp.paint(canvas, Offset(offsetX, offsetY));

    final picture = recorder.endRecording();
    final image = await picture.toImage(w, h);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();

    if (byteData == null) return LetterPixelMap._(Uint8List(0), w, h);

    final rgba = byteData.buffer.asUint8List();
    final alpha = Uint8List(w * h);
    for (int i = 0; i < w * h; i++) {
      alpha[i] = rgba[i * 4 + 3];
    }
    return LetterPixelMap._(alpha, w, h);
  }

  bool isOnLetter(Offset point) {
    final x = point.dx.round();
    final y = point.dy.round();
    if (x < 0 || y < 0 || x >= width || y >= height) return false;
    return _alpha[y * width + x] > 30;
  }

  Set<int> get letterPixelIndices {
    final set = <int>{};
    for (int i = 0; i < _alpha.length; i++) {
      if (_alpha[i] > 30) set.add(i);
    }
    return set;
  }

  int toIndex(Offset point) => point.dy.round() * width + point.dx.round();
}

// ============================================================
//  Level1WriteScreen
// ============================================================
class Level1WriteScreen extends StatefulWidget {
  const Level1WriteScreen({super.key});

  @override
  State<Level1WriteScreen> createState() => _Level1WriteScreenState();
}

class _Level1WriteScreenState extends State<Level1WriteScreen>
    with TickerProviderStateMixin {
  final List<Offset> _touchPoints = [];
  bool _completed = false;

  String get _currentLetter =>
      (ModalRoute.of(context)?.settings.arguments as Map?)?['letter']
          as String? ??
      '';

  int get _childId =>
      (ModalRoute.of(context)?.settings.arguments as Map?)?['childId'] ?? 0;

  int get _letterId =>
      (ModalRoute.of(context)?.settings.arguments as Map?)?['letterId'] ?? 0;

  static const double _brushRadius = 28;
  static const double _requiredCoverage = 0.85;

  final List<_ConfettiParticle> _particles = [];
  late AnimationController _confettiController;

  LetterPixelMap? _pixelMap;
  Set<int>? _totalLetterPixels;
  final Set<int> _coveredPixels = {};
  String _cachedLetter = '';

  double _canvasWidth = 0;
  double _canvasHeight = 0;
  DateTime _exerciseStartedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _confettiController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..addListener(() {
            setState(() {
              for (final p in _particles) {
                p.update();
              }
            });
          });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final letter = args?['letter'] as String? ?? '';
    if (letter.isNotEmpty && letter != _cachedLetter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _buildPixelMap(letter);
      });
    }
  }

  Future<void> _buildPixelMap(String letter) async {
    if (_canvasWidth == 0 || _canvasHeight == 0) return;
    final map = await LetterPixelMap.build(letter, _canvasWidth, _canvasHeight);
    if (!mounted) return;
    setState(() {
      _pixelMap = map;
      _totalLetterPixels = map.letterPixelIndices;
      _coveredPixels.clear();
      _cachedLetter = letter;
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerMoveEvent event, RenderBox box) {
    if (_completed || _pixelMap == null) return;
    final localPos = box.globalToLocal(event.position);

    if (localPos.dx < 0 ||
        localPos.dy < 0 ||
        localPos.dx > _canvasWidth ||
        localPos.dy > _canvasHeight) {
      return;
    }

    if (_touchPoints.isNotEmpty &&
        (_touchPoints.last - localPos).distance <= _brushRadius * 0.4) {
      return;
    }

    bool addedNew = false;
    final r = _brushRadius.toInt();
    final cx = localPos.dx.round();
    final cy = localPos.dy.round();

    for (int dy = -r; dy <= r; dy++) {
      for (int dx = -r; dx <= r; dx++) {
        if (dx * dx + dy * dy > r * r) continue;
        final px = cx + dx;
        final py = cy + dy;
        final pt = Offset(px.toDouble(), py.toDouble());
        if (_pixelMap!.isOnLetter(pt)) {
          final idx = _pixelMap!.toIndex(pt);
          if (_coveredPixels.add(idx)) addedNew = true;
        }
      }
    }

    setState(() => _touchPoints.add(localPos));
    if (addedNew) _checkCompletion();
  }

  void _checkCompletion() {
    if (_totalLetterPixels == null || _totalLetterPixels!.isEmpty) return;
    final coverage = _coveredPixels.length / _totalLetterPixels!.length;
    if (coverage >= _requiredCoverage) _onCompleted();
  }

  void _onCompleted() {
    if (_completed) return;
    setState(() => _completed = true);
    final duration = DateTime.now().difference(_exerciseStartedAt).inSeconds;

    // Submit writing result
    if (_childId != 0) {
      context.read<SubmissionCubit>().submit(
        childId: _childId,
        level: 'level1',
        exerciseType: 'writing',
        exerciseId: _letterId, // same as letter.id
        status: 'pass',
        attemptsCount: 0,
        duration: duration,
        totalItems: 1,
        metadata: {'letter': _currentLetter},
      );
    }

    // Check if this was the last letter (letterId == 28 = ياء)
    if (_letterId == 28 && _childId != 0) {
      context.read<ChildCubit>().updateLevel(_childId, 'level2');
    }

    final rnd = Random();
    for (int i = 0; i < 60; i++) {
      _particles.add(_ConfettiParticle(rnd));
    }
    _confettiController.repeat();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _confettiController.stop();
      final navigator = Navigator.of(context);
      Navigator.pushReplacementNamed(
        context,
        exercisesResultScreen,
        arguments: () => navigator.pop(),
      );
    });
  }

  void _reset() {
    _confettiController.stop();
    setState(() {
      _touchPoints.clear();
      _completed = false;
      _particles.clear();
      _coveredPixels.clear();
      _pixelMap = null;
      _totalLetterPixels = null;
      _cachedLetter = '';
      _exerciseStartedAt = DateTime.now();
    });
    _buildPixelMap(_currentLetter);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double boxSize = (screenSize.shortestSide * 0.75).clamp(200.0, 350.0);
    final canvasWidth = boxSize;
    final canvasHeight = boxSize;

    if (canvasWidth != _canvasWidth || canvasHeight != _canvasHeight) {
      _canvasWidth = canvasWidth;
      _canvasHeight = canvasHeight;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentLetter.isNotEmpty) _buildPixelMap(_currentLetter);
      });
    }

    return BlocBuilder<ChildCubit, ChildState>(
      builder: (context, childState) {
        return LoadingOverlay(
          isLoading: childState is ChildUpdateLoading,
          child: Scaffold(
            backgroundColor: const Color(0xFFFAEFE4),
            body: Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 48),
                            const Expanded(
                              child: Text(
                                'مشّي إصبعك على الحرف 👆',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Cairo-ExtraBold',
                                  fontSize: 18,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.black38,
                                size: 28,
                              ),
                              onPressed: _reset,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Builder(
                            builder: (ctx) => Listener(
                              onPointerMove: (event) {
                                final box =
                                    ctx.findRenderObject() as RenderBox?;
                                if (box != null) _onPointerMove(event, box);
                              },
                              child: SizedBox(
                                width: canvasWidth,
                                height: canvasHeight,
                                child: CustomPaint(
                                  painter: LetterTracePainter(
                                    letter: _currentLetter,
                                    touchPoints: List.unmodifiable(
                                      _touchPoints,
                                    ),
                                    traceColor: const Color(0xFF774019),
                                    brushRadius: _brushRadius,
                                    canvasWidth: canvasWidth,
                                    canvasHeight: canvasHeight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                if (_completed)
                  IgnorePointer(
                    child: SizedBox(
                      width: screenSize.width,
                      height: screenSize.height,
                      child: CustomPaint(painter: _ConfettiPainter(_particles)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
//  Confetti
// ============================================================
class _ConfettiParticle {
  late double x, y, speedX, speedY, size, rotation, rotationSpeed;
  late Color color;

  static const _colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
  ];

  _ConfettiParticle(Random rnd) {
    x = rnd.nextDouble();
    y = -rnd.nextDouble() * 0.3;
    speedX = (rnd.nextDouble() - 0.5) * 0.006;
    speedY = 0.003 + rnd.nextDouble() * 0.005;
    color = _colors[rnd.nextInt(_colors.length)];
    size = 8 + rnd.nextDouble() * 10;
    rotation = rnd.nextDouble() * pi * 2;
    rotationSpeed = (rnd.nextDouble() - 0.5) * 0.15;
  }

  void update() {
    x += speedX;
    y += speedY;
    rotation += rotationSpeed;
    if (y > 1.2) {
      y = -0.05;
      x = Random().nextDouble();
    }
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color.withOpacity(0.85);
      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.5,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => true;
}

// ============================================================
//  LetterTracePainter
// ============================================================
class LetterTracePainter extends CustomPainter {
  final String letter;
  final List<Offset> touchPoints;
  final Color traceColor;
  final double brushRadius;
  final double? canvasWidth;
  final double? canvasHeight;

  LetterTracePainter({
    required this.letter,
    required this.touchPoints,
    required this.traceColor,
    this.brushRadius = 24,
    this.canvasWidth,
    this.canvasHeight,
  });

  TextPainter _buildTextPainter(Size size, Color color) {
    final refWidth = canvasWidth ?? size.width;
    final fontSize = refWidth * 0.65;
    final tp = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
      textDirection: TextDirection.rtl,
    );
    tp.layout(maxWidth: size.width);
    return tp;
  }

  Offset _letterOffset(TextPainter tp, Size size) =>
      Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2);

  @override
  void paint(Canvas canvas, Size size) {
    final ghost = _buildTextPainter(size, traceColor.withOpacity(0.15));
    ghost.paint(canvas, _letterOffset(ghost, size));

    if (touchPoints.isEmpty) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.saveLayer(rect, Paint());

    final tracePaint = Paint()
      ..color = traceColor.withOpacity(0.9)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    for (final point in touchPoints) {
      canvas.drawCircle(point, brushRadius, tracePaint);
    }

    final mask = _buildTextPainter(size, Colors.black);
    canvas.saveLayer(rect, Paint()..blendMode = BlendMode.dstIn);
    mask.paint(canvas, _letterOffset(mask, size));
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(LetterTracePainter old) =>
      old.touchPoints.length != touchPoints.length || old.letter != letter;
}
