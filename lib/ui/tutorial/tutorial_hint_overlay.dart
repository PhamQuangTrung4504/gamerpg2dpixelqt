import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/game_typography.dart';
import '../../game/survival_game.dart';
import '../../game/tutorial/tutorial_manager.dart';

/// Overlay hiển thị gợi ý thao tác và mũi tên chỉ dẫn nhấp nhô (Bouncing Arrow)
class TutorialHintOverlay extends StatefulWidget {
  final SurvivalGame game;

  const TutorialHintOverlay({super.key, required this.game});

  @override
  State<TutorialHintOverlay> createState() => _TutorialHintOverlayState();
}

class _TutorialHintOverlayState extends State<TutorialHintOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    widget.game.tutorialManager.addListener(_onTutorialChanged);
  }

  @override
  void dispose() {
    widget.game.tutorialManager.removeListener(_onTutorialChanged);
    _bounceController.dispose();
    super.dispose();
  }

  void _onTutorialChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final tutorial = widget.game.tutorialManager;
    final step = tutorial.currentStep;

    if (step == PrologueStep.none || step == PrologueStep.dialogue || step == PrologueStep.cameraPan) {
      return const SizedBox.shrink();
    }

    final hintText = tutorial.currentHintText;
    final showChestArrow = step == PrologueStep.equipSword && !widget.game.overlays.isActive('inventory');
    final showInventoryArrow = step == PrologueStep.equipSword && widget.game.overlays.isActive('inventory');

    // Toàn bộ Overlay hướng dẫn/banner nổi được bọc IgnorePointer
    // để người chơi chạm xuyên qua điều khiển Joystick và các nút bấm bên dưới
    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
          // 1. Banner gợi ý thao tác trên cao màn hình
          if (hintText.isNotEmpty)
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xDD1A1A1A),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: step == PrologueStep.completed
                          ? const Color(0xFF81C784)
                          : const Color(0xFFFFD54F),
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        step == PrologueStep.completed
                            ? Icons.check_circle
                            : Icons.lightbulb,
                        color: step == PrologueStep.completed
                            ? const Color(0xFF81C784)
                            : const Color(0xFFFFD54F),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          hintText,
                          textAlign: TextAlign.center,
                          style: GameTypography.pixel(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 2. Mũi tên nhấp nhô chỉ vào icon Rương Đồ (góc trên bên phải)
          if (showChestArrow)
            AnimatedBuilder(
              animation: _bounceController,
              builder: (context, child) {
                final offsetY = sin(_bounceController.value * pi) * 6.0;
                return Positioned(
                  top: 62 + offsetY,
                  right: 30,
                  child: IgnorePointer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomPaint(
                          size: const Size(24, 24),
                          painter: PixelArrowPainter(isPointingUp: true),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xDD000000),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFFFD54F)),
                          ),
                          child: Text(
                            'Túi Đồ',
                            style: GameTypography.pixel(
                              color: const Color(0xFFFFD54F),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // 3. Mũi tên nhấp nhô bên trong Túi Đồ chỉ vào Kiếm Gỗ
          if (showInventoryArrow)
            AnimatedBuilder(
              animation: _bounceController,
              builder: (context, child) {
                final offsetX = sin(_bounceController.value * pi) * 6.0;
                return Align(
                  alignment: Alignment.center,
                  child: IgnorePointer(
                    child: Container(
                      margin: EdgeInsets.only(left: 140 + offsetX, top: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xEE2E7D32),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFA5D6A7), width: 1.5),
                        boxShadow: const [
                          BoxShadow(color: Colors.black87, blurRadius: 6),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Nhấp Kiếm Gỗ -> Bấm "Trang Bị"!',
                            style: GameTypography.pixel(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    ),
  );
}
}

/// Painter vẽ mũi tên Pixel Art sắc nét
class PixelArrowPainter extends CustomPainter {
  final bool isPointingUp;

  PixelArrowPainter({this.isPointingUp = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paintFill = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    if (isPointingUp) {
      // Mũi tên chỉ lên trên
      path.moveTo(size.width / 2, 2);
      path.lineTo(size.width - 2, size.height * 0.55);
      path.lineTo(size.width * 0.65, size.height * 0.55);
      path.lineTo(size.width * 0.65, size.height - 2);
      path.lineTo(size.width * 0.35, size.height - 2);
      path.lineTo(size.width * 0.35, size.height * 0.55);
      path.lineTo(2, size.height * 0.55);
      path.close();
    } else {
      // Mũi tên chỉ xuống dưới
      path.moveTo(size.width / 2, size.height - 2);
      path.lineTo(size.width - 2, size.height * 0.45);
      path.lineTo(size.width * 0.65, size.height * 0.45);
      path.lineTo(size.width * 0.65, 2);
      path.lineTo(size.width * 0.35, 2);
      path.lineTo(size.width * 0.35, size.height * 0.45);
      path.lineTo(2, size.height * 0.45);
      path.close();
    }

    canvas.drawPath(path, paintFill);
    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
