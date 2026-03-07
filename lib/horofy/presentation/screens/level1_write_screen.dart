import 'dart:math';
import 'package:flutter/material.dart';
import 'package:horofy/core/constants/strings.dart';

// ============================================================
//  Level1WriteScreen  –  حرف ب قابل للتتبع بالإصبع
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

  static const double _canvasSize = 300;

  // ── Confetti particles ──────────────────────────────────
  final List<_ConfettiParticle> _particles = [];
  late AnimationController _confettiController;

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
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onCompleted() {
    if (_completed) return;
    setState(() => _completed = true);

    final rnd = Random();
    for (int i = 0; i < 60; i++) {
      _particles.add(_ConfettiParticle(rnd));
    }
    _confettiController.repeat();

    // انتقل لشاشة النتيجة بعد ثانية تقريباً عشان الطفل يشوف الكونفيتي
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _confettiController.stop();
      final navigator = Navigator.of(context);
      Navigator.pushReplacementNamed(
        context,
        exercisesResultScreen,
        arguments: () {
          navigator.pop();
        },
      );
    });
  }

  void _onPointerMove(PointerMoveEvent event, RenderBox box) {
    if (_completed) return;
    final localPos = box.globalToLocal(event.position);
    if (localPos.dx < 0 ||
        localPos.dy < 0 ||
        localPos.dx > _canvasSize ||
        localPos.dy > _canvasSize)
      return;

    setState(() => _touchPoints.add(localPos));

    if (_touchPoints.length > 180) _onCompleted();
  }

  void _reset() {
    _confettiController.stop();
    setState(() {
      _touchPoints.clear();
      _completed = false;
      _particles.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFAEFE4),
      body: Stack(
        children: [
          // ── الحرف في وسط الشاشة تماماً ──────────────────
          Center(
            child: Builder(
              builder: (ctx) => Listener(
                onPointerMove: (event) {
                  final box = ctx.findRenderObject() as RenderBox?;
                  if (box != null) _onPointerMove(event, box);
                },
                child: SizedBox(
                  width: _canvasSize,
                  height: _canvasSize,
                  child: CustomPaint(
                    painter: LetterTracePainter(
                      letter: 'ب',
                      touchPoints: List.unmodifiable(_touchPoints),
                      traceColor: const Color(0xFF774019),
                      brushRadius: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── تعليمات (بس لو مش مكتمل) ────────────────────
          if (!_completed)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: const Text(
                'مشّي إصبعك على الحرف 👆',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  color: Colors.black45,
                ),
              ),
            ),

          // ── زرار reset ───────────────────────────────────
          if (!_completed)
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black38),
                onPressed: _reset,
              ),
            ),

          // ── Confetti ─────────────────────────────────────
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
    );
  }
}

// ============================================================
//  Confetti Particle
// ============================================================
class _ConfettiParticle {
  late double x;
  late double y;
  late double speedX;
  late double speedY;
  late Color color;
  late double size;
  late double rotation;
  late double rotationSpeed;

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

// ============================================================
//  Confetti Painter
// ============================================================
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

  LetterTracePainter({
    required this.letter,
    required this.touchPoints,
    required this.traceColor,
    this.brushRadius = 24,
  });

  TextPainter _buildTextPainter(Size size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: size.width * 0.85,
          color: color,
          fontWeight: FontWeight.bold,
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
    // ١: الحرف الباهت
    final ghost = _buildTextPainter(size, traceColor.withOpacity(0.15));
    ghost.paint(canvas, _letterOffset(ghost, size));

    if (touchPoints.isEmpty) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // ٢: layer للـ trace مع mask
    canvas.saveLayer(rect, Paint());

    final tracePaint = Paint()
      ..color = traceColor.withOpacity(0.9)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    for (final point in touchPoints) {
      canvas.drawCircle(point, brushRadius, tracePaint);
    }

    // mask بشكل الحرف
    final mask = _buildTextPainter(size, Colors.black);
    canvas.saveLayer(rect, Paint()..blendMode = BlendMode.dstIn);
    mask.paint(canvas, _letterOffset(mask, size));
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(LetterTracePainter old) =>
      old.touchPoints.length != touchPoints.length;
}
