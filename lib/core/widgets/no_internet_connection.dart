import 'dart:math';
import 'package:flutter/material.dart';
import 'package:horofy/core/style/app_colors.dart';

class _WordPuzzle {
  final String word;
  final String imagePath;
  final String hint;
  const _WordPuzzle({required this.word, required this.imagePath, required this.hint});
}

const List<_WordPuzzle> _puzzles = [
  _WordPuzzle(word: 'باب', imagePath: 'assets/images/level2/door.png', hint: 'ادخل منه!'),
  _WordPuzzle(word: 'بيت', imagePath: 'assets/images/level2/house.png', hint: 'نسكن فيه'),
  _WordPuzzle(word: 'بطه', imagePath: 'assets/images/level5/duck.png', hint: 'تعيش في الماء'),
  _WordPuzzle(word: 'بقرة', imagePath: 'assets/images/level4/cow.png', hint: 'حيوان كبير'),
];

class _LetterTile {
  final String id;
  final String char;
  const _LetterTile({required this.id, required this.char});
}

class NoInternetConnection extends StatefulWidget {
  const NoInternetConnection({super.key});

  @override
  State<NoInternetConnection> createState() => _NoInternetConnectionState();
}

class _NoInternetConnectionState extends State<NoInternetConnection>
    with TickerProviderStateMixin {

  int _puzzleIndex = 0;
  int _score = 0;
  int _streak = 0;

  late List<_LetterTile?> _bank;
  late List<_LetterTile?> _slots;

  late AnimationController _shakeController;
  late AnimationController _celebrationController;
  late Animation<double> _shakeAnim;
  late Animation<double> _celebrationAnim;

  bool _isCorrect = false;
  bool _showCelebration = false;

  _WordPuzzle get _currentPuzzle => _puzzles[_puzzleIndex % _puzzles.length];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeController);
    _celebrationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _celebrationAnim = CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut);
    _initPuzzle();
  }

  void _initPuzzle() {
    final chars = _currentPuzzle.word.characters.toList();
    final shuffled = List<String>.from(chars)..shuffle(Random());
    setState(() {
      _bank = List.generate(shuffled.length, (i) => _LetterTile(id: 'tile_${_puzzleIndex}_$i', char: shuffled[i]));
      _slots = List.filled(chars.length, null);
      _isCorrect = false;
      _showCelebration = false;
    });
  }

  void _dropOnSlot(int slotIndex, _LetterTile tile) {
    if (_isCorrect) return;
    if (_slots[slotIndex] != null) return;
    final bankIndex = _bank.indexWhere((t) => t?.id == tile.id);
    final prevSlot = _slots.indexWhere((t) => t?.id == tile.id);
    setState(() {
      if (bankIndex != -1) _bank[bankIndex] = null;
      if (prevSlot != -1) _slots[prevSlot] = null;
      _slots[slotIndex] = tile;
    });
    _checkAnswer();
  }

  void _dropOnBank(_LetterTile tile) {
    if (_isCorrect) return;
    final prevSlot = _slots.indexWhere((t) => t?.id == tile.id);
    if (prevSlot == -1) return;
    final emptyBank = _bank.indexWhere((t) => t == null);
    setState(() {
      _slots[prevSlot] = null;
      if (emptyBank != -1) _bank[emptyBank] = tile;
      else _bank.add(tile);
    });
  }

  void _checkAnswer() {
    if (_slots.any((s) => s == null)) return;
    final answered = _slots.map((s) => s!.char).join();
    if (answered == _currentPuzzle.word) {
      setState(() { _isCorrect = true; _showCelebration = true; _score++; _streak++; });
      _celebrationController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) { _puzzleIndex++; _initPuzzle(); }
      });
    } else {
      setState(() => _streak = 0);
      _shakeController.forward(from: 0).then((_) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          for (int i = _slots.length - 1; i >= 0; i--) {
            if (_slots[i] != null) {
              final tile = _slots[i]!;
              final emptyBank = _bank.indexWhere((t) => t == null);
              setState(() {
                _slots[i] = null;
                if (emptyBank != -1) _bank[emptyBank] = tile;
                else _bank.add(tile);
              });
              break;
            }
          }
        });
      });
    }
  }

  void _resetPuzzle() => _initPuzzle();

  @override
  void dispose() {
    _shakeController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            ..._buildBgDots(),
            Column(
              children: [
                _buildTopBar(),
                _buildOfflineBadge(),
                const SizedBox(height: 16),
                _buildWordImage(),
                const SizedBox(height: 6),
                Text(_currentPuzzle.hint, style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: Colors.grey.shade500)),
                const SizedBox(height: 24),
                _buildSlots(),
                const SizedBox(height: 10),
                Text('✏️ اسحب الحرف للمكان الصحيح', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey.shade400)),
                const SizedBox(height: 20),
                _buildBank(),
                const Spacer(),
                _buildResetBtn(),
                const SizedBox(height: 16),
              ],
            ),
            if (_showCelebration) _buildCelebration(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBgDots() {
    final data = [[30.0,80.0,60.0],[320.0,120.0,40.0],[50.0,300.0,80.0],[340.0,420.0,50.0],[15.0,550.0,70.0]];
    return data.map((d) => Positioned(left: d[0], top: d[1], child: Container(width: d[2], height: d[2], decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.05))))).toList();
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _chip('⭐ $_score', AppColors.primary.withOpacity(0.12), AppColors.primary),
          const Text('رتّب الحروف', style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
          _chip('$_streak 🔥', _streak > 0 ? Colors.orange.withOpacity(0.15) : Colors.grey.withOpacity(0.1), _streak > 0 ? Colors.orange : Colors.grey),
        ],
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  Widget _buildOfflineBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange.shade200)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.wifi_off_rounded, size: 15, color: Colors.orange.shade600),
        const SizedBox(width: 6),
        Text('! بدون إنترنت — العب واستنى الاتصال', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.orange.shade700)),
      ]),
    );
  }

  Widget _buildWordImage() {
    return AnimatedBuilder(
      animation: _celebrationAnim,
      builder: (_, child) => Transform.scale(scale: _showCelebration ? 0.9 + _celebrationAnim.value * 0.12 : 1.0, child: child),
      child: Container(
        width: 150, height: 150,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Image.asset(_currentPuzzle.imagePath, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Center(child: Text('🖼️', style: TextStyle(fontSize: 48)))),
        ),
      ),
    );
  }

  Widget _buildSlots() {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) => Transform.translate(offset: Offset(sin(_shakeAnim.value * pi * 6) * 8, 0), child: child),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_slots.length, (i) => _buildSlot(i)).reversed.toList(),
      ),
    );
  }

  Widget _buildSlot(int index) {
    final tile = _slots[index];
    return DragTarget<_LetterTile>(
      onWillAcceptWithDetails: (details) => !_isCorrect && _slots[index] == null,
      onAcceptWithDetails: (details) => _dropOnSlot(index, details.data),
      builder: (_, candidateData, __) {
        final isHovered = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 64, height: 72,
          decoration: BoxDecoration(
            color: tile != null ? (_isCorrect ? Colors.green.shade50 : Colors.white) : (isHovered ? AppColors.primary.withOpacity(0.08) : AppColors.background),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tile != null ? (_isCorrect ? Colors.green.shade400 : AppColors.primary.withOpacity(0.5)) : (isHovered ? AppColors.primary : AppColors.primary.withOpacity(0.2)),
              width: isHovered ? 3 : 2.5,
            ),
            boxShadow: tile != null ? [BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))] : null,
          ),
          child: tile != null
              ? _buildDraggableTile(tile, inSlot: true)
              : Center(child: Container(width: 28, height: 3, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
        );
      },
    );
  }

  Widget _buildBank() {
    return DragTarget<_LetterTile>(
      onWillAcceptWithDetails: (details) => _slots.any((s) => s?.id == details.data.id),
      onAcceptWithDetails: (details) => _dropOnBank(details.data),
      builder: (_, candidateData, __) {
        final isHovered = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isHovered ? AppColors.primary.withOpacity(0.06) : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isHovered ? AppColors.primary.withOpacity(0.4) : Colors.transparent, width: 2),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12, runSpacing: 12,
            children: _bank.asMap().entries.map((entry) {
              final tile = entry.value;
              if (tile == null) return const SizedBox(width: 64, height: 64);
              return _buildDraggableTile(tile, inSlot: false);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDraggableTile(_LetterTile tile, {required bool inSlot}) {
    Widget tileWidget = Container(
      width: 64, height: 64,
      decoration: inSlot ? null : BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.85), AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 4, offset: const Offset(2, -2)),
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4, offset: const Offset(-2, 2)),
          BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: Center(
        child: Text(tile.char, style: TextStyle(fontFamily: 'Cairo', fontSize: 30, fontWeight: FontWeight.bold, color: inSlot ? AppColors.primary : Colors.white)),
      ),
    );

    return Draggable<_LetterTile>(
      data: tile,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 68, height: 68,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.95), AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 16, spreadRadius: 2)],
          ),
          child: Center(child: Text(tile.char, style: const TextStyle(fontFamily: 'Cairo', fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white))),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: tileWidget),
      child: tileWidget,
    );
  }

  Widget _buildResetBtn() {
    return TextButton.icon(
      onPressed: _resetPuzzle,
      icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
      label: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: AppColors.primary)),
    );
  }

  Widget _buildCelebration() {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _celebrationAnim,
          builder: (_, __) => Transform.scale(
            scale: _celebrationAnim.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(color: Colors.green.shade600, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)]),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('🎉', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                const Text('أحسنت!', style: TextStyle(fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(_currentPuzzle.word, style: const TextStyle(fontFamily: 'Cairo', fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}