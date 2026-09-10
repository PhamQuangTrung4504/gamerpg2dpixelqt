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
    final levelUpHint = tutorial.levelUpHint;
    final isInventoryOpen = widget.game.overlays.isActive('inventory');
    final isSkillTreeOpen = widget.game.overlays.isActive('SkillOverlay');
    final isStatsOpen = widget.game.overlays.isActive('StatsOverlay');
    final isAnyModalOpen = isInventoryOpen || isSkillTreeOpen || isStatsOpen;

    if (step == PrologueStep.none && levelUpHint == null) {
      return const SizedBox.shrink();
    }

    final isLevelUp = levelUpHint != null;
    final hintText = levelUpHint ?? (isAnyModalOpen ? '' : tutorial.currentHintText);
    final showChestArrow = step == PrologueStep.openInventory && !isInventoryOpen;
    final showSkillArrow = step == PrologueStep.openSkillTree && !isSkillTreeOpen;
    final showStatsArrow = step == PrologueStep.openStats && !isStatsOpen;

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
                      color: isLevelUp
                          ? const Color(0xFFFF5252)
                          : (step == PrologueStep.completed
                              ? const Color(0xFF81C784)
                              : const Color(0xFFFFD54F)),
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
                        isLevelUp
                            ? Icons.arrow_circle_up
                            : (step == PrologueStep.completed
                                ? Icons.check_circle
                                : Icons.lightbulb),
                        color: isLevelUp
                            ? const Color(0xFFFF5252)
                            : (step == PrologueStep.completed
                                ? const Color(0xFF81C784)
                                : const Color(0xFFFFD54F)),
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

          // 3. Mũi tên nhấp nhô chỉ vào icon Kỹ Năng (góc trên bên phải)
          if (showSkillArrow)
            AnimatedBuilder(
              animation: _bounceController,
              builder: (context, child) {
                final offsetY = sin(_bounceController.value * pi) * 6.0;
                return Positioned(
                  top: 62 + offsetY,
                  right: 74,
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
                            'Kỹ Năng',
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

          // 4. Mũi tên nhấp nhô chỉ vào icon Thuộc Tính (góc trên bên phải)
          if (showStatsArrow)
            AnimatedBuilder(
              animation: _bounceController,
              builder: (context, child) {
                final offsetY = sin(_bounceController.value * pi) * 6.0;
                return Positioned(
                  top: 62 + offsetY,
                  right: 118,
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
                            'Thuộc Tính',
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
